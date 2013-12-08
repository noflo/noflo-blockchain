noflo = require 'noflo'
chai = require 'chai' unless chai
ToBitcoin = require '../components/ToBitcoin.coffee'

describe 'ToBitcoin component', ->
  c = null
  currency = null
  value = null
  bitcoin = null
  beforeEach ->
    c = ToBitcoin.getComponent()
    currency = noflo.internalSocket.createSocket()
    value = noflo.internalSocket.createSocket()
    bitcoin = noflo.internalSocket.createSocket()
    c.inPorts.currency.attach currency
    c.inPorts.value.attach value
    c.outPorts.bitcoin.attach bitcoin

  describe 'converting EUR', ->
    it 'should be able to return BTC', (done) ->
      bitcoin.on 'data', (data) ->
        chai.expect(data).to.be.a 'number'
        done()
      currency.send 'EUR'
      value.send 2.5
  describe 'converting USD', ->
    it 'should be able to return BTC', (done) ->
      bitcoin.on 'data', (data) ->
        chai.expect(data).to.be.a 'number'
        done()
      currency.send 'USD'
      value.send 1205
