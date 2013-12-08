noflo = require 'noflo'
https = require 'https'
url = require 'url'

class CreateReceiveAddress extends noflo.AsyncComponent
  constructor: ->
    @wallet = null
    @inPorts =
      wallet: new noflo.Port 'string'
      callback: new noflo.Port 'string'
    @outPorts =
      address: new noflo.Port 'string'
      error: new noflo.Port 'object'

    @inPorts.wallet.on 'data', (@wallet) =>

      super 'callback', 'address'

  doAsync: (cbURL, callback) ->
    return callback new Error 'Missing wallet address' unless @wallet
    address = url.format
      protocol: 'https'
      hostname: 'blockchain.info'
      pathname: '/api/receive'
      query:
        method: 'create'
        address: @wallet
        callback: cbURL
    wallet = @wallet
    req = https.get address, (res) =>
      unless res.statusCode is 200
        return callback new Error "Request failed, #{res.statusCode}"
      data = ''
      res.on 'data', (chunk) ->
        data += chunk
      res.on 'end', =>
        newAddress = JSON.parse data
        unless newAddress.destination is wallet
          return callback new Error "Received invalid destination address"
        unless newAddress.callback_url is cbURL
          return callback new Error "Received invalid callback URL"
        @outPorts.address.beginGroup cbURL
        @outPorts.address.send newAddress.input_address
        @outPorts.address.endGroup()
        @outPorts.address.disconnect()
        callback()
    req.on 'error', (e) =>
      callback e

exports.getComponent = -> new CreateReceiveAddress
