var ERC20Simple = artifacts.require("ERC20Simple");
var {deployProxy ,upgradeProxy } = require('@openzeppelin/truffle-upgrades')

module.exports = async function(deployer) {

    const min = 100000
    const cap = 1000000
    const burn = 10

    await deployProxy(ERC20Simple,[min,cap,burn],{deployer, kind: 'uups', initializer: 'initialize'});
}