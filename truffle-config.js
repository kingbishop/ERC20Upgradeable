require('dotenv').config()
const PrivateKeyProvider = require("truffle-privatekey-provider")

//

module.exports = {
  /**
   * Networks define how you connect to your ethereum client and let you set the
   * defaults web3 uses to send transactions. If you don't specify one truffle
   * will spin up a development blockchain for you on port 9545 when you
   * run `develop` or `test`. You can ask a truffle command to use a specific
   * network from the command line, e.g
   *
   * $ truffle test --network <network-name>
   */
  plugins: [
    'truffle-plugin-verify'
  ],

  api_keys: {
    etherscan: process.env.ETHERSCAN_API_KEY
  },

  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*" // Match any network id
    },
    develop: {
      port: 8545
    },
    rinkeby: {
      provider: () => new PrivateKeyProvider(process.env.PRIVATE_KEY, process.env.RINKEBY_INFURA_URL),
      network_id: '4',
      skipDryRun: true
    },
    ropsten: {
      provider: () => new PrivateKeyProvider(process.env.PRIVATE_KEY, process.env.ROPSTEN_INFURA_URL),
      network_id: '3',
      skipDryRun: true
    }
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.12",    // Fetch exact version from solc-bin (default: truffle's version)
    }
  },

};