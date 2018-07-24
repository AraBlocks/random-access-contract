const bufferFrom = require('buffer-from')
const isBuffer = require('is-buffer')
const storage = require('random-access-storage')

module.exports = RandomAccessContract

function RandomAccessContract(opts) {
  if (null == opts || 'object' != typeof opts) {
    throw new TypeError(
      "RandomAccessContract: Expecting object.")
  }

  if (null == opts.account || (
    false == isBuffer(opts.account) && 'string' != typeof opts.account
  )) {
    throw new TypeError(
      "RandomAccessContract: Expecting account to be a buffer.")
  }

  if (null == opts.contract || 'object' != typeof opts.contract) {
    throw new TypeError(
      "RandomAccessContract: Expecting contract object.")
  }

  if (null == opts.pointer || false == isBuffer(opts.pointer)) {
    throw new TypeError(
      "RandomAccessContract: Expecting pointer to be a buffer.")
  }

  const { contract, account, pointer, hash } = opts
  const { methods } = contract

  if (null == methods || 'object' != typeof methods) {
    throw new TypeError(
      "RandomAccessContract: Expecting contract methods to be an object.")
  }

  const self = storage({ read, write, del, stat })

  return self

  function read(req) {
    const { offset, size } = req
    if ('function' != typeof methods.read) {
      return req.callback(new TypeError(
        "RandomAccessContract: Expecting read contract method."))
    }

    return methods
      .read(ethify(pointer), offset, size)
      .call(onread)

    function onread(err, res) {
      if (err) { return req.callback(err) }
      req.callback(null, fromHex(res) || Buffer.alloc(0))
    }
  }

  function write(req) {
    const { data, offset } = req
    const tx = transaction()

    if ('function' != typeof methods.write) {
      return req.callback(new TypeError(
        "RandomAccessContract: Expecting write contract method."))
    }

    return methods
      .read(ethify(pointer), offset, data.length)
      .call(onread)

    function onread(err, res) {
      if (!err && res) {
        if (0 == Buffer.compare(data, fromHex(res))) {
          //return onreadhit()
        }
      }

      return onreadmiss()
    }

    function onreadhit() {
      console.log('hit');
      return onwrite(null)
    }

    function onreadmiss() {
      console.log(ethify(pointer), ethify(data), offset, data.length);
      return methods
        .write(ethify(pointer), ethify(data), offset, data.length)
        .send({value: 0}, onwrite)
        .on('receipt', onreceipt)
        .on('confirmation', onconfirmation)
    }

    function onwrite(err) {
      return req.callback(err)
    }

    function onreceipt(receipt) {
      tx.receipt = receipt
      process.nextTick(() => self.emit('transaction', tx))
    }

    function onconfirmation(confirmation, receipt) {
      tx.confirmations ++
    }
  }

  function del(req) {
    const { size, offset } = req
    const tx = transaction()

    if ('function' != typeof methods.del) {
      return req.callback(new TypeError(
        "RandomAccessContract: Expecting del contract method."))
    }

    return methods
      .del(ethify(pointer), offset, size)
      .send({value: 0}, ondel)
      .on('receipt', onreceipt)
      .on('confirmation', onconfirmation)

    function ondel(err) {
      return req.callback(err)
    }

    function onreceipt(receipt) {
      tx.receipt = receipt
      process.nextTick(() => self.emit('transaction', tx))
    }

    function onconfirmation(confirmation, receipt) {
      tx.confirmations ++
    }
  }

  function stat(req) {
    if ('function' != typeof methods.stat) {
      return req.callback(new TypeError(
        "RandomAccessContract: Expecting stat contract method."))
    }

    return methods
      .stat(ethify(pointer))
      .call(onstat)

    function onstat(err, res) {
      if (err) { return req.callback(err) }
      req.callback(null, {size: parseInt(res) || 0})
    }
  }
}

function transaction() {
  return { receipt: null, confirmations: 0 }
}

function toHex(buf) {
  if (isBuffer(buf)) {
    return buf.toString('hex')
  } else if ('number' == typeof buf) {
    return toHex(bufferFrom([buf]))
  } else if ('string' == typeof buf) {
    return toHex(bufferFrom(buf))
  } else {
    return toHex(bufferFrom(buf))
  }
}

function fromHex(bytes) {
  if ('string' == typeof bytes) {
    bytes = bytes.replace(/^0x/, '')
    return bufferFrom(bytes, 'hex')
  } else if (bytes) {
    return bufferFrom(bytes.toString(), 'hex')
  } else {
    return null
  }
}

function ethify(x) {
  return '0x'+toHex(x)
}
