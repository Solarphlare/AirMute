import Foundation

public class ResponseGetVoiceSettings: Codable {
    let data: ResponseGetVoiceSettingsData
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decode(ResponseGetVoiceSettingsData.self, forKey: .data)
    }
    
    static func from(data: Data) throws -> ResponseGetVoiceSettings {
        return try JSONDecoder().decode(Self.self, from: data)
    }
}

public class ResponseGetVoiceSettingsData: Codable {
    /// Whether or not the user is muted.
    let mute: Bool
    /// Whether or not the user is deafened. If this is `true`, `mute` will also be `true`, but not vice versa.
    let deaf: Bool
}
