noflo = require 'noflo'
chai = require 'chai' unless chai
ToBitcoin = require '../components/ToBitcoin.coffee'

describe 'ToBitcoin component', ->
  c = null
  currency = null
  value = null
  bitcoin = null
  error = null
  beforeEach ->
    c = ToBitcoin.getComponent()
    currency = noflo.internalSocket.createSocket()
    value = noflo.internalSocket.createSocket()
    bitcoin = noflo.internalSocket.createSocket()
    error = noflo.internalSocket.createSocket()
    c.inPorts.currency.attach currency
    c.inPorts.value.attach value
    c.outPorts.bitcoin.attach bitcoin
    c.outPorts.error.attach error

  describe 'converting EUR', ->
    it 'should be able to return BTC', (done) ->
      bitcoin.on 'data', (data) ->
        chai.expect(data).to.be.a 'number'
        done()
      error.on 'data', (data) ->
        done data
      currency.send 'EUR'
      currency.disconnect()
      value.send 2.5
      value.disconnect()
  describe 'converting USD', ->
    it 'should be able to return BTC', (done) ->
      bitcoin.on 'data', (data) ->
        chai.expect(data).to.be.a 'number'
        done()
      error.on 'data', (data) ->
        done data
      currency.send 'USD'
      currency.disconnect()
      value.send 1205
      value.disconnect()
