TokenManager = require 'meshblu-core-manager-token'
http = require 'http'

class RemoveRootSessionToken
  constructor: ({datastore, pepper, uuidAliasResolver}) ->
    @tokenManager = new TokenManager {datastore, pepper, uuidAliasResolver}

  _doCallback: (request, code, callback) =>
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]
    callback null, response

  do: (request, callback) =>
    {uuid} = request.metadata.auth
    message = JSON.parse request.rawData

    @tokenManager.removeRootToken {uuid}, (error) =>
      return callback error if error?
      return @_doCallback request, 204, callback

module.exports = RemoveRootSessionToken
