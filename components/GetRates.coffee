noflo = require 'noflo'
https = require 'https'

exports.getComponent = ->
  component = new noflo.Component

  component.inPorts.add 'fetch', datatype: 'bang'
  component.outPorts.add 'rates', datatype: 'object'
  component.outPorts.add 'error', datatype: 'object'

  noflo.helpers.WirePattern component,
    in: 'fetch'
    out: 'rates'
    async: true
    forwardGroups: true
  , (fetch, groups, out, callback) ->
    req = https.get 'https://blockchain.info/ticker', (res) ->
      unless res.statusCode is 200
        err = new Error "Request failed, #{res.statusCode}"
        err.kind = 'api_error'
        err.code = 'blockchain_request_failed'
        return callback err
      data = ''
      res.on 'data', (chunk) ->
        data += chunk
      res.on 'end', ->
        out.send JSON.parse data
        callback()
    req.on 'error', (e) ->
      callback e

  return component
