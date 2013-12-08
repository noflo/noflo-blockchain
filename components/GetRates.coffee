noflo = require 'noflo'
https = require 'https'

class GetRates extends noflo.AsyncComponent
  constructor: ->
    @inPorts =
      fetch: new noflo.Port 'bang'
    @outPorts =
      rates: new noflo.Port 'object'
      error: new noflo.Port 'object'

    super 'fetch', 'rates'

  doAsync: (fetch, callback) ->
    req = https.get 'https://blockchain.info/ticker', (res) =>
      unless res.statusCode is 200
        return callback new Error "Request failed, #{res.statusCode}"
      data = ''
      res.on 'data', (chunk) ->
        data += chunk
      res.on 'end', =>
        @outPorts.rates.send JSON.parse data
        @outPorts.rates.disconnect()
        callback()
    req.on 'error', (e) =>
      callback e

exports.getComponent = -> new GetRates
