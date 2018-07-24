pragma solidity ^0.4.24;

import { RandomAccessInterface16 } from "./RandomAccessInterface.sol";
import { RandomAccessStorage } from "./RandomAccessStorage.sol";

contract RandomAccessContract16 is RandomAccessInterface16 {
  RandomAccessStorage.RandomAccessMemory16 private ram;

  function page(bytes16 ptr)
  internal view returns (bytes storage) {
    return ram.pages[ptr];
  }

  function stat(bytes16 ptr)
  public constant returns (uint256) {
    return RandomAccessStorage.stat(page(ptr));
  }

  function write(bytes16 ptr, bytes buf, uint256 off, uint256 size)
  public {
    RandomAccessStorage.write(page(ptr), buf, off, size);
  }

  function read(bytes16 ptr, uint256 off, uint256 size)
  public view returns (bytes memory) {
    return RandomAccessStorage.read(page(ptr), off, size);
  }

  function del(bytes16 ptr, uint256 off, uint256 size)
  public {
    return RandomAccessStorage.del(page(ptr), off, size);
  }
}
