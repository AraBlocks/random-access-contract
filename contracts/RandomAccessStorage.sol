pragma solidity ^0.4.23;

/**
 * The `RandomAccessStorage` contract is an interface for volatile
 * memory access.
 */
contract RandomAccessStorage {

  /**
   * Storage stat indicating time.
   */
  struct Stat { uint size; }

  /**
   * `ram` is a _mapping_ between a memory pointer address to
   * a mapping of memory cells or arbitrary length.
   */
  mapping(bytes => mapping(uint => bytes1)) private ram;
  mapping(bytes => Stat) private stats;

  /**
   * Modifier to ensure a given bytes pointer is of "valid"
   * length (len > 0)
   */
  modifier valid(bytes pointer) {
    require(length(pointer) > 0);
    _;
  }

  /**
   * Modifier to ensure a given bytes pointer is of
   * "valid" length (len > 0) and a memory cell at a
   * given offset is also of "valid" length.
   */
  modifier access(bytes pointer, uint offset, uint len) {
    require(length(pointer) > 0);
    for (uint i = 0; i < len; ++i) {
      require(ram[pointer][offset + i].length > 0);
    }
    _;
  }

  /**
   * Helper function to return length of bytes
   */
  function length(bytes pointer)
  private pure returns (uint) {
    return uint(bytes(pointer).length);
  }

  /**
   * Reads a memory cell at a given `offset` for a `pointer`.
   */
  function read(bytes pointer, uint offset, uint len)
  valid(pointer) access(pointer, offset, len)
  public view returns (bytes memory) {
    bytes memory out = new bytes(len);
    for (uint i = 0; i < len; ++i) {
      out[i] = ram[pointer][offset + i];
    }
    return out;
  }

  /**
   * Writes a buffer to a memory cell at a given `offset` for a `pointer`.
   */
  function write(bytes pointer, bytes buffer, uint offset, uint len)
  valid(pointer) valid(buffer)
  public {
    for (uint i = 0; i < len; ++i) {
      ram[pointer][offset + i] = buffer[i];
    }
  }
}
