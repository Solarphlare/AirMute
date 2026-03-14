import Foundation
import os
import AppKit

let logger = AppLogger()

func generateNonce(async: Bool = false) -> String {
    return "\(async ? "async" : "sync");\(UUID().uuidString)"
}

extension RPC {
    public func fetchAccessToken(code: String, timeout: Int? = 10000, redirectURI: String = "") throws -> AccessToken {
        let response = try httpRequest(
            endpoint: "https://discord.com/api/oauth2/token",
            method: "POST",
            timeout: timeout,
            headers: ["Authorization": "Bearer \("")"],
            parameters: [
                "client_id": self.clientId,
                "client_secret": self.clientSecret,
                "code": code,
                "grant_type": "authorization_code",
                "redirect_uri": redirectURI
            ])

        return try AccessToken.from(data: response)
    }

    // Seems to be outdated, see: https://github.com/discord/discord-api-docs/issues/2700#issuecomment-797700709
    public func fetchRPCToken(timeout: Int? = 10000) throws -> RPCToken {
        let response = try httpRequest(
            endpoint: "https://discord.com/api/oauth2/token/rpc",
            method: "POST",
            timeout: timeout,
            headers: ["Authorization": "Bearer \("")"],
            parameters: [
                "client_id": self.clientId,
                "client_secret": self.clientSecret
            ])

        return try RPCToken.from(data: response)
    }
}

func isNonceAsync(nonce: String) throws -> Bool {
    let components = nonce.components(separatedBy: ";")
    if components.count != 2 || (components[0] != "async" && components[0] != "sync") {
        throw NonceError.invalid(nonce: nonce)
    }
    return components[0] == "async"
}

public func fetchUserAvatarData(id: String, avatar: String, timeout: Int? = 10000) throws -> Data {
    return try httpRequest(
        endpoint: "https://cdn.discordapp.com/avatars/\(id)/\(avatar).png",
        method: "GET",
        timeout: timeout
    )
}

public func fetchUserAvatarImage(id: String, avatar: String, timeout: Int? = 10000) throws -> NSImage {
    return NSImage(data: try fetchUserAvatarData(id: id, avatar: avatar, timeout: timeout))!
}

// Internal methods
func httpRequest(
    endpoint: String,
    method: String,
    timeout: Int?,
    headers: [String: String] = [:],
    parameters: [String: Any] = [:]) throws -> Data {
    let semaphore = DispatchSemaphore(value: 0)
    var response: Data?
    var error: Error?
    var request = URLRequest(url: URL(string: endpoint)!)

    request.httpMethod = method
    for (key, value) in headers {
        request.setValue(value, forHTTPHeaderField: key)
    }
    request.httpBody = parameters.percentEncoded()

    let task = URLSession.shared.dataTask(with: request) { data, resp, err in
        defer { semaphore.signal() }

        guard let data = data, err == nil && (200 ... 299) ~= ((resp as? HTTPURLResponse)?.statusCode ?? 0) else {
            error = HTTPError.failed(code: (resp as? HTTPURLResponse)?.statusCode, error: err)
            return
        }

        response = data
    }
    task.resume()

    if let timeout = timeout,
       semaphore.wait(timeout: .now() + .milliseconds(timeout)) == .timedOut {
        throw HTTPError.timeout(timeout: timeout)
    } else if timeout == nil {
        semaphore.wait()
    }

    if let error = error { throw error }

    return response!
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

