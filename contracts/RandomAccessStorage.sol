pragma solidity ^0.4.24;

/**
 */
library RandomAccessStorage {

  /**
   * The `struct RandomAccessStorage32` type maps a 32 byte pointer
   * to a variable byte ranges.
   */
  struct RandomAccessMemory32 { mapping (bytes32 => bytes) pages; }

  /**
   * The `struct RandomAccessStorage16` type maps a 16 byte pointer
   * to a variable byte ranges.
   */
  struct RandomAccessMemory16 { mapping (bytes16 => bytes) pages; }

  /**
   * The `struct RandomAccessStorage8` type maps a 8 byte pointer
   * to a variable byte ranges.
   */
  struct RandomAccessMemory8 { mapping (bytes8 => bytes) pages; }

  /**
   * The `notnull` modifier requires that a pointer to
   * a byte range in memory is not "null", or non-zero length.
   */
  modifier notnull(bytes memory p) {
    require(
      p.length > 0,
      "RandomAccessStorage: notnull: Empty bytes.");
    _;
  }

  /**
   * The `notzero` modifier requires that a 256-bit unsigned
   * integer value be a positive non-zero value.
   */
  modifier notzero(uint256 n) {
    require(
      n > 0,
      "RandomAccessStorage: notzero: Expecting non-zero value integer.");
    _;
  }

  /**
   */
  function stat(bytes storage page)
  public constant returns (uint256 length) {
    assembly {
      let pslot := sload(page_slot)
      // x & y
      length := div(and(pslot, sub(mul(0x100, iszero(and(pslot, 1))), 1)), 2)
    }

    return length;
  }

  /**
   */
  function write(bytes storage page, bytes buf, uint256 off, uint256 size)
  notnull(buf) notzero(size)
  public {
    if (off + size > page.length) {
      page.length = off + size;
    }

    assembly {
      // Read the first 32 bytes of page storage, which is the length
      // of the array. (We don't need to use the offset into the slot
      // because arrays use the entire slot.)
      let pslot := sload(page_slot)

      // Arrays of 31 bytes or less have an even value in their slot,
      // while longer arrays have an odd value. The actual length is
      // the slot divided by two for odd values, and the lowest order
      // byte divided by two for even values.
      // If the slot is even, bitwise and the slot with 255 and divide by
      // two to get the length. If the slot is odd, bitwise and the slot
      // with -1 and divide by two.
      let slength := div(and(pslot, sub(mul(0x100, iszero(and(pslot, 1))), 1)), 2)
      let mlength := mload(buf)
      // 32 + 1 - 32 + 1
      let newlength := add(add(slength, sub(off, slength)), mlength)
      //let newlength := add(mload(off, mlength)
      mstore(0x0, page_slot)
      let sc := keccak256(0x0, add(0x20, off))
      sstore(sc, mload(add(buf, 0x20)))
    }

    return;
  }

  /**
   */
  function read(bytes storage page, uint256 off, uint256 size)
  //notzero(size)
  public view returns (bytes memory) {
    bytes memory buf = new bytes(size);

    for (uint256 i = 0; i < size; ++i) {
      buf[i] = page[off + i];
    }

    return buf;
  }

  /**
   */
  function del(bytes storage page, uint256 off, uint256 size)
  notzero(size)
  public {
    if (off + size > page.length) {
      page.length = off;
    }

    //bytes memory zero = new bytes(size);
    //concat(page, zero, off);
  }


  /**
   * Ported from - https://github.com/GNSPS/solidity-bytes-utils/blob/master/contracts/BytesLib.sol
   */
  function concat(bytes storage page, bytes memory buf, uint256 off)
  notnull(buf)
  public {
    assembly {
      // Read the first 32 bytes of page storage, which is the length
      // of the array. (We don't need to use the offset into the slot
      // because arrays use the entire slot.)
      let pslot := sload(page_slot)

      // Arrays of 31 bytes or less have an even value in their slot,
      // while longer arrays have an odd value. The actual length is
      // the slot divided by two for odd values, and the lowest order
      // byte divided by two for even values.
      // If the slot is even, bitwise and the slot with 255 and divide by
      // two to get the length. If the slot is odd, bitwise and the slot
      // with -1 and divide by two.
      let slength := div(and(pslot, sub(mul(0x100, iszero(and(pslot, 1))), 1)), 2)
      let mlength := mload(buf)
      let newlength := add(slength, mlength)

      // slength can contain both the length and contents of the array
      // if length < 32 bytes so let's prepare for that
      // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
      switch add(lt(slength, 32), lt(newlength, 32))
      case 2 {
        // Since the new array still fits in the slot, we just need to
        // update the contents of the slot.
        // uint256(bytes_storage) = uint256(bytes_storage) + uint256(bytes_memory) + new_length
        sstore(page_slot,
          // all the modifications to the slot are inside this
          // next block
          add(pslot,
            // we can just add to the slot contents because the
            // bytes we want to change are the LSBs
            // increase length by the double of the memory bytes length
            add(mul(mlength, 2),
                // load the bytes from memory
                // zero all bytes to the right
                mul(div(mload(add(buf, 0x20)), exp(0x100, sub(32, mlength))),
                    // and now shift left the number of bytes to
                    // leave space for the length in the slot
                    exp(0x100, sub(32, newlength)))
            )
          )
        )
     }

      case 1 {
        // The stored value fits in the slot, but the combined value
        // will exceed it.
        // get the keccak hash to get the contents of the array
        mstore(0x0, page_slot)
        let sc := add(keccak256(0x0, 0x20), div(slength, 32))

        // save new length
        sstore(page_slot, add(mul(newlength, 2), 1))

        // The contents of the buf array start 32 bytes into
        // the structure. Our first read should obtain the `submod`
        // bytes that can fit into the unused space in the last word
        // of the stored array. To get this, we read 32 bytes starting
        // from `submod`, so the data we read overlaps with the array
        // contents by `submod` bytes. Masking the lowest-order
        // `submod` bytes allows us to add that value directly to the
        // stored value.

        let submod := sub(32, slength)
        let mc := add(buf, submod)
        let end := add(buf, mlength)
        let mask := sub(exp(0x100, submod), 1)

        sstore(
          sc,
          add(
            and(
              pslot,
              0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00),
          and(mload(mc), mask)))

        for {
          mc := add(mc, 0x20)
          sc := add(sc, 1)
        } lt(mc, end) {
          sc := add(sc, 1)
          mc := add(mc, 0x20)
        } {
          sstore(sc, mload(mc))
        }

        mask := exp(0x100, sub(mc, end))
        sstore(sc, mul(div(mload(mc), mask), mask))
      }

      default {
        // get the keccak hash to get the contents of the array
        mstore(0x0, page_slot)
        // Start copying to the last used word of the stored array.
        let sc := add(keccak256(0x0, 0x20), div(slength, 32))

        // save new length
        sstore(page_slot, add(mul(newlength, 2), 1))

        // Copy over the first `submod` bytes of the new data as in
        // case 1 above.
        let slengthmod := mod(slength, 32)
        let mlengthmod := mod(mlength, 32)
        let submod := sub(32, slengthmod)
        let mc := add(buf, submod)
        let end := add(buf, mlength)
        let mask := sub(exp(0x100, submod), 1)

        sstore(sc, add(sload(sc), and(mload(mc), mask)))

        for {
          sc := add(sc, 1)
          mc := add(mc, 0x20)
        } lt(mc, end) {
          sc := add(sc, 1)
          mc := add(mc, 0x20)
        } {
          sstore(sc, mload(mc))
        }

        mask := exp(0x100, sub(mc, end))
        sstore(sc, mul(div(mload(mc), mask), mask))
      }
    }

  }
}
