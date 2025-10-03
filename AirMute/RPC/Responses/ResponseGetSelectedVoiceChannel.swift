import Foundation

public class ResponseGetSelectedVoiceChannel: Codable {
    let data: ResponseGetSelectedVoiceChannelData?
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decodeIfPresent(ResponseGetSelectedVoiceChannelData.self, forKey: .data)
    }
    
    static func from(data: Data) throws -> ResponseGetSelectedVoiceChannel {
        return try JSONDecoder().decode(Self.self, from: data)
    }
}

public class ResponseGetSelectedVoiceChannelData: Codable {
    /// The ID of the channel.
    let id: String
    /// The ID of the guild that this voice channel belongs to. `nil` if this channel is a DM.
    let guildId: String?
    /// The name of the channel.
    let name: String
    /// The type of the channel.
    let type: ChannelType
    /// The channel's topic string.
    let topic: String
    /// The bitrate of the channel.
    let bitrate: Int
    /// The user limit for the channel, if this channel's type is`.guildVoice`.
    let userLimit: Int
    /// The position of the channel within its category, if this channel's type is `type == .guildVoice`.
    let position: Int
    /* let voiceStates: [VoiceState] */
    /* let messages: [Message] */
    
    enum CodingKeys: String, CodingKey {
        case id
        case guildId = "guild_id"
        case name
        case type
        case topic
        case bitrate
        case userLimit = "user_limit"
        case position
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.guildId = try container.decodeIfPresent(String.self, forKey: .guildId)
        self.name = try container.decode(String.self, forKey: .name)
        self.type = try container.decode(ChannelType.self, forKey: .type)
        self.topic = try container.decode(String.self, forKey: .topic)
        self.bitrate = try container.decode(Int.self, forKey: .bitrate)
        self.userLimit = try container.decode(Int.self, forKey: .userLimit)
        self.position = try container.decode(Int.self, forKey: .position)
    }
}

