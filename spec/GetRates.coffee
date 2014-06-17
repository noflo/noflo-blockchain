noflo = require 'noflo'
chai = require 'chai' unless chai
GetRates = require '../components/GetRates.coffee'

describe 'GetRates component', ->
  c = GetRates.getComponent()
  fetch = noflo.internalSocket.createSocket()
  rates = noflo.internalSocket.createSocket()
  error = noflo.internalSocket.createSocket()
  c.inPorts.fetch.attach fetch
  c.outPorts.rates.attach rates
  c.outPorts.error.attach error

  describe 'fetching rates', ->
    it 'should return rates for USD and EUR', (done) ->
      rates.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.USD).to.be.an 'object'
        chai.expect(data.USD.last).to.be.a 'number'
        chai.expect(data.EUR).to.be.an 'object'
        done()
      error.on 'data', (data) ->
        done data
      fetch.send ''
      fetch.disconnect()
