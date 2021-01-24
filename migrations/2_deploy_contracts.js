const BethToken = artifacts.require('BethToken')
const Beth = artifacts.require('Beth')

module.exports = async function(deployer, network, accounts) {
  // Deploy BethToken
  await deployer.deploy(BethToken)
  const bethToken = await BethToken.deployed()

  // Deploy Beth
  await deployer.deploy(Beth, bethToken.address)
  const beth = await Beth.deployed()
}
