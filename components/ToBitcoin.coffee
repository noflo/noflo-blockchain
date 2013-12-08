noflo = require 'noflo'
https = require 'https'
url = require 'url'

class ToBitcoin extends noflo.AsyncComponent
  constructor: ->
    @currency = null
    @inPorts =
      currency: new noflo.Port 'string'
      value: new noflo.Port 'number'
    @outPorts =
      bitcoin: new noflo.Port 'number'
      error: new noflo.Port 'object'

    @inPorts.currency.on 'data', (@currency) =>

    super 'value', 'bitcoin'

  doAsync: (value, callback) ->
    return callback new Error 'Missing currency' unless @currency
    address = url.format
      protocol: 'https'
      hostname: 'blockchain.info'
      pathname: '/tobtc'
      query:
        currency: @currency
        value: value
    req = https.get address, (res) =>
      unless res.statusCode is 200
        return callback new Error "Request failed, #{res.statusCode}"
      data = ''
      res.on 'data', (chunk) ->
        data += chunk
      res.on 'end', =>
        @outPorts.bitcoin.beginGroup value
        @outPorts.bitcoin.send parseFloat data
        @outPorts.bitcoin.endGroup()
        @outPorts.bitcoin.disconnect()
        callback()
    req.on 'error', (e) =>
      callback e

exports.getComponent = -> new ToBitcoin
