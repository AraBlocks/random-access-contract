const RandomAccessStorage = artifacts.require('RandomAccessStorage')

module.exports = (deployer) => {
  deployer.deploy(RandomAccessStorage)
}
