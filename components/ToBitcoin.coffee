noflo = require 'noflo'
https = require 'https'
url = require 'url'

exports.getComponent = ->
  component = new noflo.Component
  component.currency = null

  component.inPorts.add 'currency', datatype: 'string', (event, payload) ->
    component.currency = payload if event is 'data'
  component.inPorts.add 'value', datatype: 'number'
  component.outPorts.add 'bitcoin', datatype: 'number'
  component.outPorts.add 'error', datatype: 'object'

  noflo.helpers.WirePattern component,
    in: 'value'
    out: 'bitcoin'
    async: true
    forwardGroups: true
  , (value, groups, out, callback) ->
    unless component.currency
      err = new Error 'Missing currency'
      err.kind = 'internal_error'
      err.code = 'missing_currency'
      err.param = 'currency'
      return callback err
    address = url.format
      protocol: 'https'
      hostname: 'blockchain.info'
      pathname: '/tobtc'
      query:
        currency: component.currency
        value: value
    req = https.get address, (res) ->
      unless res.statusCode is 200
        err = new Error "Request failed, #{res.statusCode}"
        err.kind = 'api_error'
        err.code = 'blockchain_request_failed'
        return callback err
      data = ''
      res.on 'data', (chunk) ->
        data += chunk
      res.on 'end', ->
        out.beginGroup value
        out.send parseFloat data
        out.endGroup()
        callback()
    req.on 'error', (e) ->
      callback e

  return component
