pragma solidity ^0.4.24;

import { RandomAccessInterface32 } from "./RandomAccessInterface.sol";
import { RandomAccessStorage } from "./RandomAccessStorage.sol";

contract RandomAccessContract32 is RandomAccessInterface32 {
  RandomAccessStorage.RandomAccessMemory32 private ram;

  function page(bytes32 ptr)
  internal view returns (bytes storage) {
    return ram.pages[ptr];
  }

  function stat(bytes32 ptr)
  public constant returns (uint256) {
    return RandomAccessStorage.stat(page(ptr));
  }

  function write(bytes32 ptr, bytes buf, uint256 off, uint256 size)
  public {
    RandomAccessStorage.write(page(ptr), buf, off, size);
  }

  function read(bytes32 ptr, uint256 off, uint256 size)
  public view returns (bytes memory) {
    return RandomAccessStorage.read(page(ptr), off, size);
  }

  function del(bytes32 ptr, uint256 off, uint256 size)
  public {
    return RandomAccessStorage.del(page(ptr), off, size);
  }
}
