import Foundation
import AppKit

private enum UserError: Error {
    case userHasNoAvatar
}

public struct AvatarDecorationData: Codable {
    public let asset: String
    public let skuId: String?
}

public class User: Codable {
    public let id: String
    public let username: String
    public let globalName: String
    public let discriminator: String
    public let avatar: String?
    public let avatarDecorationData: AvatarDecorationData?
    public let bot: Bool?
    public let system: Bool?
    public let mfaEnabled: Bool?
    public let locale: String?
    public let verified: Bool?
    public let email: String?
    public let flags: Int?
    public let premiumType: PremiumType?
    public let publicFlags: Int?

    private enum CodingKeys: String, CodingKey {
        case id
        case username
        case globalName  = "global_name"
        case discriminator
        case avatar
        case avatarDecorationData = "avatar_decoration_data"
        case bot
        case system
        case mfaEnabled  = "mfa_enabled"
        case locale
        case verified
        case email
        case flags
        case premiumType = "premium_type"
        case publicFlags = "public_flags"
    }

    public func fetchAvatarData(timeout: Int? = 10000) throws -> Data {
        guard let avatarHash = self.avatar else {
            throw UserError.userHasNoAvatar
        }
        
        return try fetchUserAvatarData(id: self.id, avatar: avatarHash, timeout: timeout)
    }

    public func fetchAvatarImage(timeout: Int? = 10000) throws -> NSImage {
        guard let avatarHash = self.avatar else {
            throw UserError.userHasNoAvatar
        }
        
        return try fetchUserAvatarImage(id: self.id, avatar: avatarHash, timeout: timeout)
    }
}
