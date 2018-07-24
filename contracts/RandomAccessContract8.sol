pragma solidity ^0.4.24;

import { RandomAccessInterface8 } from "./RandomAccessInterface.sol";
import { RandomAccessStorage } from "./RandomAccessStorage.sol";

contract RandomAccessContract8 is RandomAccessInterface8 {
  RandomAccessStorage.RandomAccessMemory8 private ram;

  function page(bytes8 ptr)
  internal view returns (bytes storage) {
    return ram.pages[ptr];
  }

  function stat(bytes8 ptr)
  public constant returns (uint256) {
    return RandomAccessStorage.stat(page(ptr));
  }

  function write(bytes8 ptr, bytes buf, uint256 off, uint256 size)
  public {
    RandomAccessStorage.write(page(ptr), buf, off, size);
  }

  function read(bytes8 ptr, uint256 off, uint256 size)
  public view returns (bytes memory) {
    return RandomAccessStorage.read(page(ptr), off, size);
  }

  function del(bytes8 ptr, uint256 off, uint256 size)
  public {
    return RandomAccessStorage.del(page(ptr), off, size);
  }
}
