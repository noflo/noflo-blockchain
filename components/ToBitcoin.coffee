noflo = require 'noflo'
https = require 'https'
url = require 'url'

exports.getComponent = ->
  component = new noflo.Component

  component.inPorts.add 'currency',
    datatype: 'string'
    required: true
  component.inPorts.add 'value', datatype: 'number'
  component.outPorts.add 'bitcoin', datatype: 'number'
  component.outPorts.add 'error', datatype: 'object'

  noflo.helpers.WirePattern component,
    in: 'value'
    params: 'currency'
    out: 'bitcoin'
    async: true
    forwardGroups: true
  , (value, groups, out, callback) ->
    address = url.format
      protocol: 'https'
      hostname: 'blockchain.info'
      pathname: '/tobtc'
      query:
        currency: component.params.currency
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
