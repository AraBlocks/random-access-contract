const RandomAccessContract32 = artifacts.require('RandomAccessContract32')
const RandomAccessContract16 = artifacts.require('RandomAccessContract16')
const RandomAccessContract8 = artifacts.require('RandomAccessContract8')
const RandomAccessContract = artifacts.require('RandomAccessContract')

const RandomAccessStorage = artifacts.require('RandomAccessStorage')

module.exports = (deployer) => {
  //deployer.deploy(RandomAccessInterface32)
  //deployer.deploy(RandomAccessInterface16)
  //deployer.deploy(RandomAccessInterface8)
  //deployer.deploy(RandomAccessInterface)

  deployer.deploy(RandomAccessStorage)

  deployer.link(RandomAccessStorage, RandomAccessContract32)
  deployer.link(RandomAccessStorage, RandomAccessContract16)
  deployer.link(RandomAccessStorage, RandomAccessContract8)

  deployer.link(RandomAccessStorage, RandomAccessContract)
  deployer.deploy(RandomAccessContract32)
  deployer.deploy(RandomAccessContract16)
  deployer.deploy(RandomAccessContract8)
  deployer.deploy(RandomAccessContract)
}
