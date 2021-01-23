const BethToken = artifacts.require('BethToken')
const Bet = artifacts.require('Bet')

module.exports = async function(deployer, network, accounts) {
  // Deploy BethToken
  await deployer.deploy(BethToken)
  const bethToken = await BethToken.deployed()

  // Deploy Beth
  await deployer.deploy(Bet, bethToken.address)
  const bet = await Bet.deployed()
}
