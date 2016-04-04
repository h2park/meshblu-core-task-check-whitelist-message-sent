http = require 'http'
CheckWhitelistMessageSent = require '../'

describe 'CheckWhitelistMessageSent', ->
  beforeEach ->
    @whitelistManager =
      checkMessageSent: sinon.stub()

    @sut = new CheckWhitelistMessageSent
      whitelistManager: @whitelistManager

  describe '->do', ->
    describe "when called with a job whos fromUuid and auth.uuid don't match", ->
      beforeEach (done) ->
        job =
          metadata:
            auth:
              uuid: 'green-blue'
              token: 'blue-purple'
            toUuid: 'bright-green'
            fromUuid: 'dim-green'
            responseId: 'yellow-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'yellow-green'

      it 'should get have the status code of 403', ->
        expect(@response.metadata.code).to.equal 403

      it 'should get have the status of ', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[403]

    describe 'when called with a valid job', ->
      beforeEach (done) ->
        @whitelistManager.checkMessageSent.yields null, true
        job =
          metadata:
            auth:
              uuid: 'green-blue'
            toUuid: 'bright-green'
            fromUuid: 'green-blue'
            responseId: 'yellow-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'yellow-green'

      it 'should get have the status code of 204', ->
        expect(@response.metadata.code).to.equal 204

      it 'should get have the status of ', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[204]

    describe 'when called with a valid job without a from', ->
      beforeEach (done) ->
        @whitelistManager.checkMessageSent.yields null, true
        job =
          metadata:
            auth:
              uuid: 'green-blue'
              token: 'blue-purple'
            toUuid: 'bright-green'
            responseId: 'yellow-green'
        @sut.do job, (error, @response) => done error

      it 'should infer the fromUuid and yield a 204', ->
        expect(@response.metadata.code).to.equal 204

    describe 'when called with a different valid job', ->
      beforeEach (done) ->
        @whitelistManager.checkMessageSent.yields null, true
        job =
          metadata:
            auth:
              uuid: 'dim-green'
              token: 'blue-lime-green'
            toUuid: 'hot-yellow'
            fromUuid: 'dim-green'
            responseId: 'purple-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 204', ->
        expect(@response.metadata.code).to.equal 204

      it 'should get have the status of OK', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[204]

    describe 'when called with a job that with a device that has an invalid whitelist', ->
      beforeEach (done) ->
        @whitelistManager.checkMessageSent.yields null, false
        job =
          metadata:
            auth:
              uuid: 'puke-green'
              token: 'blue-lime-green'
            toUuid: 'super-purple'
            fromUuid: 'not-so-super-purple'
            responseId: 'purple-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 403', ->
        expect(@response.metadata.code).to.equal 403

      it 'should get have the status of Forbidden', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[403]

    describe 'when called and the checkMessageSent yields an error', ->
      beforeEach (done) ->
        @whitelistManager.checkMessageSent.yields new Error "black-n-black"
        job =
          metadata:
            auth:
              uuid: 'puke-green'
              token: 'blue-lime-green'
            toUuid: 'green-bomb'
            fromUuid: 'puke-green'
            responseId: 'purple-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 500', ->
        expect(@response.metadata.code).to.equal 500

      it 'should get have the status of Forbidden', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[500]
