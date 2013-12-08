noflo = require 'noflo'
chai = require 'chai' unless chai
GetRates = require '../components/GetRates.coffee'

describe 'GetRates component', ->
  c = null
  fetch = null
  rates = null
  beforeEach ->
    c = GetRates.getComponent()
    fetch = noflo.internalSocket.createSocket()
    rates = noflo.internalSocket.createSocket()
    c.inPorts.fetch.attach fetch
    c.outPorts.rates.attach rates

  describe 'fetching rates', ->
    it 'should return rates for USD and EUR', (done) ->
      rates.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.USD).to.be.an 'object'
        chai.expect(data.USD.last).to.be.a 'number'
        chai.expect(data.EUR).to.be.an 'object'
        done()
      fetch.send ''
