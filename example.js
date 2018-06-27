const { abi, networks } = require('./build/contracts/RandomAccessStorage')
const { keyPair } = require('hypercore/lib/crypto')
const hyperdrive = require('hyperdrive')
const Web3 = require('web3')
const raf = require('random-access-file')
const ram = require('random-access-memory')
const rac = require('./')

//console.log(require('./build/contracts/RandomAccessStorage'));
const web3 = new Web3('ws://127.0.0.1:9545') // truffle
//const web3 = new Web3('ws://127.0.0.1:8546') // geth --testnet --ws
const address = 4447 in networks ? networks[4447].address :'0xf12b5dd4ead5f743c6baa640b0216200e89b60da'
const { publicKey, secretKey } = keyPair(Buffer.from(address))

web3.eth.getAccounts(onaccounts)

function onaccounts(err, accounts) {
  if (err) { throw err }
  const [account] = accounts
  const contract = new web3.eth.Contract(abi, address, { from: account })
  const drive = hyperdrive((filename) => {
    if ( filename.includes('signatures') || filename.includes('tree')) {
      const pointer = Buffer.concat([publicKey, Buffer.from(filename)])
      //console.log(filename, pointer.toString('hex'));
      return rac({account, contract, pointer})
    } else {
      return raf(filename)
    }
  })

  drive.on('transaction', console.log)
  drive.ready(onready)

  function onready() {
    console.log('ready');
    drive.writeFile('/hello', Buffer.from('world'), () => {
      drive.readFile('/hello', 'utf8', console.log)
    })
  }
}
