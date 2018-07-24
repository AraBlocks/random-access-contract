pragma solidity ^0.4.24;

/**
 */
contract RandomAccessInterface32 {

  /**
   */
  constructor() internal { }

  /**
   */
  function stat(bytes32 ptr)
  public constant returns (uint256);

  /**
   */
  function write(bytes32 ptr, bytes buf, uint256 off, uint256 size)
  public;

  /**
   */
  function read(bytes32 ptr, uint256 off, uint256 size)
  public view returns (bytes memory);

  /**
   */
  function del(bytes32 ptr, uint256 off, uint256 size)
  public;
}

/**
 */
contract RandomAccessInterface16 {

  /**
   */
  constructor() internal { }

  /**
   */
  function stat(bytes16 ptr)
  public constant returns (uint256);

  /**
   */
  function write(bytes16 ptr, bytes buf, uint256 off, uint256 size)
  public;

  /**
   */
  function read(bytes16 ptr, uint256 off, uint256 size)
  public view returns (bytes memory);

  /**
   */
  function del(bytes16 ptr, uint256 off, uint256 size)
  public;
}

/**
 */
contract RandomAccessInterface8 {

  /**
   */
  constructor() internal { }

  /**
   */
  function stat(bytes8 ptr)
  public constant returns (uint256);

  /**
   */
  function write(bytes8 ptr, bytes buf, uint256 off, uint256 size)
  public;

  /**
   */
  function read(bytes8 ptr, uint256 off, uint256 size)
  public view returns (bytes memory);

  /**
   */
  function del(bytes8 ptr, uint256 off, uint256 size)
  public;
}

/**
 */
contract RandomAccessInterface is RandomAccessInterface32 {}
