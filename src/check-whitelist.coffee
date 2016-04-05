WhitelistManager = require 'meshblu-core-manager-whitelist'
http             = require 'http'

class CheckWhitelist
  constructor: ({datastore, @whitelistManager, uuidAliasResolver}) ->
    @whitelistManager ?= new WhitelistManager {datastore, uuidAliasResolver}

  do: (job, callback) =>
    {toUuid, fromUuid, responseId, auth} = job.metadata
    fromUuid ?= auth.uuid
    return @sendResponse responseId, 422, null, callback unless fromUuid? && toUuid?
    @whitelistManager.canSend {fromUuid, toUuid}, (error, verified) =>
      return @sendResponse responseId, 500, error, callback if error?
      return @sendResponse responseId, 403, null, callback unless verified
      @sendResponse responseId, 204, null, callback

  sendResponse: (responseId, code, error, callback) =>
    if error?
      errorHash = message: error.message

    callback null,
      metadata:
        responseId: responseId
        code: code
        status: http.STATUS_CODES[code]
        error: errorHash

module.exports = CheckWhitelist
