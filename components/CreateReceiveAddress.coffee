noflo = require 'noflo'
https = require 'https'
url = require 'url'

exports.getComponent = ->
  component = new noflo.Component
  component.wallet = null

  component.inPorts.add 'wallet', datatype: 'string', (event, payload) ->
    component.wallet = payload if event is 'data'
  component.inPorts.add 'callback', datatype: 'string'
  component.outPorts.add 'address', datatype: 'string'
  component.outPorts.add 'error', datatype: 'object'

  noflo.helpers.MultiError component, 'CreateReceiveAddress'

  noflo.helpers.WirePattern component,
    in: ['wallet', 'callback']
    out: 'address'
    async: true
    forwardGroups: true
  , (input, groups, out, callback) ->
    address = url.format
      protocol: 'https'
      hostname: 'blockchain.info'
      pathname: '/api/receive'
      query:
        method: 'create'
        address: input.wallet
        callback: input.callback

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
        newAddress = JSON.parse data
        unless newAddress.destination is input.wallet
          err = new Error "Received invalid destination address"
          err.kind = 'api_error'
          err.code = 'blockchain_invalid_destination'
          component.error err
        unless newAddress.callback_url is input.callback
          err = new Error "Received invalid callback URL"
          err.kind = 'api_error'
          err.code = 'blockchain_invalid_callback_url'
          component.error err
        return callback no if component.hasErrors
        out.beginGroup input.callback
        out.send newAddress.input_address
        out.endGroup()
        callback()
    req.on 'error', (e) ->
      callback e

  return component
