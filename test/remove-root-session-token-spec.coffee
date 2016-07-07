Datastore  = require 'meshblu-core-datastore'
RemoveRootSessionToken = require '../'
mongojs    = require 'mongojs'

describe 'RemoveRootSessionToken', ->
  beforeEach (done) ->
    @uuidAliasResolver = resolve: (uuid, callback) => callback null, uuid
    database = mongojs 'meshblu-core-task-check-token', ['tokens']
    @datastore = new Datastore
      database: database
      collection: 'tokens'

    database.tokens.remove done

  beforeEach ->
    @sut = new RemoveRootSessionToken
      datastore: @datastore
      pepper: 'totally-a-secret'
      uuidAliasResolver: @uuidAliasResolver

  describe '->do', ->
    context 'when a root token exists', ->
      beforeEach (done) ->
        @datastore.insert { uuid: 'electric-eels', root: true }, done

      beforeEach (done) ->
        request =
          metadata:
            responseId: 'its-electric'
            auth:
              uuid: 'electric-eels'
          rawData: '{}'

        @sut.do request, (error, @response) => done error

      it 'should return a 204', ->
        expectedResponse =
          metadata:
            responseId: 'its-electric'
            code: 204
            status: 'No Content'
        expect(@response).to.deep.equal expectedResponse

      it 'should not exist in the database', (done) ->
        @datastore.findOne { uuid: 'electric-eels', root: true }, (error, record) =>
          return done error if error?
          expect(record).to.not.exist
          done()

    context 'when a root token does not exist', ->
      beforeEach (done) ->
        @datastore.insert { uuid: 'electric-eels' }, done

      beforeEach (done) ->
        request =
          metadata:
            responseId: 'its-electric'
            auth:
              uuid: 'electric-eels'
          rawData: '{}'

        @sut.do request, (error, @response) => done error

      it 'should return a 204', ->
        expectedResponse =
          metadata:
            responseId: 'its-electric'
            code: 204
            status: 'No Content'
        expect(@response).to.deep.equal expectedResponse

      it 'should not exist in the database', (done) ->
        @datastore.findOne { uuid: 'electric-eels', root: true }, (error, record) =>
          return done error if error?
          expect(record).to.not.exist
          done()
