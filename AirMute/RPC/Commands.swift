import Foundation

extension RPC {
    public func authorize(
        oAuth2Scopes: [OAuth2Scope],
        username: String? = nil,
        rpcToken: String? = nil) throws -> ResponseAuthorize {
        let nonce = generateNonce()
        let request = try RequestAuthorize(
            nonce: nonce,
            clientID: self.clientId,
            scopes: oAuth2Scopes,
            rpcToken: rpcToken,
            username: username
        )
        let requestJSON = try request.jsonString()
        let response = try syncResponse(requestJSON: requestJSON, nonce: nonce, disableTimeout: true)
        return try ResponseAuthorize.from(data: response)
    }

    public func authorizeAsync(
        oAuth2Scopes: [OAuth2Scope],
        username: String? = nil,
        rpcToken: String? = nil) throws -> String {
        let nonce = generateNonce(async: true)
        let request = try RequestAuthorize(
            nonce: nonce,
            clientID: self.clientId,
            scopes: oAuth2Scopes,
            rpcToken: rpcToken,
            username: username
        )
        let requestJSON = try request.jsonString()

        try self.send(requestJSON, .frame)
        return nonce
    }

    public func authenticate(accessToken: String) throws -> ResponseAuthenticate {
        let nonce = generateNonce()
        let request = try RequestAuthenticate(nonce: nonce, accessToken: accessToken)
        let requestJSON = try request.jsonString()

        let response = try syncResponse(requestJSON: requestJSON, nonce: nonce)
        return try ResponseAuthenticate.from(data: response)
    }

    public func authenticateAsync(accessToken: String) throws -> String {
        let nonce = generateNonce()
        let request = try RequestAuthenticate(nonce: nonce, accessToken: accessToken)
        let requestJSON = try request.jsonString()

        try self.send(requestJSON, .frame)
        return nonce
    }

    public func subscribe(event: EventType, id: String? = nil) throws -> ResponseSubscribe {
        logger.info("Registering subscription for event type \(event.rawValue)")
        let nonce = generateNonce()
        let request = try RequestSubscribe(evt: event, nonce: nonce, id: id)
        let requestJSON = try request.jsonString()

        let response = try syncResponse(requestJSON: requestJSON, nonce: nonce)
        return try ResponseSubscribe.from(data: response)
    }

    public func subscribeAsync(event: EventType, id: String? = nil) throws -> String {
        let nonce = generateNonce(async: true)
        let request = try RequestSubscribe(evt: event, nonce: nonce, id: id)
        let requestJSON = try request.jsonString()

        try self.send(requestJSON, .frame)
        return nonce
    }

    public func unsubscribe(event: EventType, id: String? = nil) throws -> ResponseUnsubscribe {
        let nonce = generateNonce()
        let request = try RequestUnsubscribe(evt: event, nonce: nonce, id: id)
        let requestJSON = try request.jsonString()

        let response = try syncResponse(requestJSON: requestJSON, nonce: nonce)
        return try ResponseUnsubscribe.from(data: response)
    }

    public func unsubscribeAsync(event: EventType, id: String? = nil) throws -> String {
        let nonce = generateNonce(async: true)
        let request = try RequestUnsubscribe(evt: event, nonce: nonce, id: id)
        let requestJSON = try request.jsonString()

        try self.send(requestJSON, .frame)
        return nonce
    }
}
