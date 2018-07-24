const { crypto_generichash_batch } = require('sodium-universal')
const { abi, networks } = require('./build/contracts/RandomAccessContract')
const { keyPair } = require('hypercore/lib/crypto')
const hyperdrive = require('hyperdrive')
const Web3 = require('web3')
const pify = require('pify')
const raf = require('random-access-file')
const ram = require('random-access-memory')
const rac = require('./')

const web3 = new Web3('ws://127.0.0.1:9545') // truffle
//const web3 = new Web3('ws://127.0.0.1:8546') // geth --testnet --ws
const address = 4447 in networks ? networks[4447].address :'0xf12b5dd4ead5f743c6baa640b0216200e89b60da'
const { publicKey, secretKey } = keyPair(Buffer.from(address))

web3.eth.getAccounts(onaccounts)

async function onaccounts(err, accounts) {
  if (err) { throw err }
  const [account] = accounts
  const contract = new web3.eth.Contract(abi, address, {
    from: account, gas: 6000000,
  })

  //if (0) {
  if (1) {
    const pointer = Buffer.alloc(32)
    crypto_generichash_batch(pointer, [Buffer.from('hello')])
    const store = pify(rac({account, contract, pointer }))
    //const buffer = Buffer.from('beep')
    //buffer.fill('22')
    //const buffer = Buffer.from('hello')
    const buffer = Buffer.from('ze')
    let gas = 0
    let off = 0

    store.on('transaction', (tx) => console.log(gas += tx.receipt.cumulativeGasUsed))

    await store.write(0, Buffer.from('h'))
    try {
      console.log(await store.stat())
      print(await store.read(0, 1))
    } catch (err) { console.log(err) ; }

    await store.write(1, Buffer.from('e'))
    try {
      console.log(await store.stat())
      print(await store.read(0, 2))
    } catch (err) { console.log(err) ; }

    await store.write(1, Buffer.from('e'))
    try {
      console.log(await store.stat())
      print(await store.read(0, 2))
    } catch (err) { console.log(err) ; }

    await store.write(2, Buffer.from('l'))
    try {
      console.log(await store.stat())
      print(await store.read(0, 3))
    } catch (err) { console.log(err) ; }

    await store.write(3, Buffer.from('l'))
    try {
      console.log(await store.stat())
      print(await store.read(0, 4))
    } catch (err) { console.log(err) ; }

    await store.write(4, Buffer.from('e'))
    try {
      console.log(await store.stat())
      print(await store.read(0, 5))
    } catch (err) { console.log(err) ; }
    //await store.write(0, Buffer.from('h'))
    //console.log(await store.stat());

    const { size } = await store.stat()
    const buf = await store.read(0, size)

    return

    function print(buf) {
     console.log(buf, buf && buf.toString('utf8'))
    }
  }

  const drive = hyperdrive((filename) => {
    console.log(filename);
    if (filename.includes('metadata/signatures') || filename.includes('metadata/tree')) {
      const tmp = Buffer.concat([publicKey, Buffer.from(filename)])
      const pointer = Buffer.alloc(32)
      crypto_generichash_batch(pointer, [tmp])
      //console.log(filename, pointer.toString('hex'));
      const store = rac({account, contract, pointer})
      store.on('transaction', (tx) => drive.emit('transaction', tx))
      return store
    } else {
      return raf(filename)
    }
  })

  let gas = 0
  //drive.on('transaction', (tx) => console.log(gas += tx.receipt.cumulativeGasUsed))
  drive.on('transaction', (tx) => console.log(gas += tx.receipt.gasUsed))
  drive.ready(onready)

  function onready() {
    console.log('ready');
    drive.writeFile('/hello', Buffer.from('world'), () => {
      drive.readFile('/hello', 'utf8', console.log)
    })
  }
}
