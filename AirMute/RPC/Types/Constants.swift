// See https://github.com/davfsa/discord-api-docs/blob/4013288bebb5748ec701c94c52164af9b29c66d5/docs/topics/OAuth2.md#oauth2-scopes
public enum OAuth2Scope: String, Codable {
    case activitiesRead             = "activities.read"
    case activitiesWrite            = "activities.write"
    case applicationsBuildsRead     = "applications.builds.read"
    case applicationsBuildsUpload   = "applications.builds.upload"
    case applicationsCommands       = "applications.commands"
    case applicationsCommandsUpdate = "applications.commands.update"
    case applicationsEntitlements   = "applications.entitlements"
    case applicationsStoreUpdate    = "applications.store.update"
    case bot                        = "bot"
    case connections                = "connections"
    case email                      = "email"
    case gdmJoin                    = "gdm.join"
    case guilds                     = "guilds"
    case guildsJoin                 = "guilds.join"
    case identify                   = "identify"
    case messagesRead               = "messages.read"
    case relationshipsRead          = "relationships.read"
    case rpc                        = "rpc"
    case rpcActivitiesWrite         = "rpc.activities.write"
    case rpcNotificationsRead       = "rpc.notifications.read"
    case rpcVoiceRead               = "rpc.voice.read"
    case rpcVoiceWrite              = "rpc.voice.write"
    case webhookIncoming            = "webhook.incoming"
}

// See https://github.com/discord/discord-api-docs/blob/8ed15ce2a11beab51918a084cfd5450ea7a3a211/docs/topics/Opcodes_and_Status_Codes.md#rpc-error-codes
public enum ErrorCode: Int, Codable {
    case unknownError                    = 1000
    case invalidPayload                  = 4000
    case invalidCommand                  = 4002
    case invalidGuild                    = 4003
    case invalidEvent                    = 4004
    case invalidChannel                  = 4005
    case invalidPermissions              = 4006
    case invalidClientID                 = 4007
    case invalidOrigin                   = 4008
    case invalidToken                    = 4009
    case invalidUser                     = 4010
    case oAuth2Error                     = 5000
    case selectChannelTimedOut           = 5001
    case getGuildTimedOut                = 5002
    case selectVoiceForceRequired        = 5003
    case captureShortcutAlreadyListening = 5004
}

// See https://github.com/discord/discord-api-docs/blob/8ed15ce2a11beab51918a084cfd5450ea7a3a211/docs/topics/Opcodes_and_Status_Codes.md#rpc-close-event-codes
public enum CloseEventCode: Int, Codable {
    case invalidClientID   = 4000
    case invalidOrigin     = 4001
    case rateLimited       = 4002
    case tokenRevoked      = 4003
    case invalidVersion    = 4004
    case invalidEncoding   = 4005

    case socketDisconnected = 0 // Not in Discord API, added for convenience
}

// See https://github.com/discord/discord-api-docs/blob/8ed15ce2a11beab51918a084cfd5450ea7a3a211/docs/topics/RPC.md#rpc-commands
public enum CommandType: String, Codable {
    case dispatch                = "DISPATCH"
    case authorize               = "AUTHORIZE"
    case authenticate            = "AUTHENTICATE"
    case getGuild                = "GET_GUILD"
    case getGuilds               = "GET_GUILDS"
    case getChannel              = "GET_CHANNEL"
    case getChannels             = "GET_CHANNELS"
    case subscribe               = "SUBSCRIBE"
    case unsubscribe             = "UNSUBSCRIBE"
    case setUserVoiceSettings    = "SET_USER_VOICE_SETTINGS"
    case selectVoiceChannel      = "SELECT_VOICE_CHANNEL"
    case getSelectedVoiceChannel = "GET_SELECTED_VOICE_CHANNEL"
    case selectTextChannel       = "SELECT_TEXT_CHANNEL"
    case getVoiceSettings        = "GET_VOICE_SETTINGS"
    case setVoiceSettings        = "SET_VOICE_SETTINGS"
    case captureShortcut         = "CAPTURE_SHORTCUT"
    case setCertifiedDevices     = "SET_CERTIFIED_DEVICES"
    case setActivity             = "SET_ACTIVITY"
    case sendActivityJoinInvite  = "SEND_ACTIVITY_JOIN_INVITE"
    case closeActivityRequest    = "CLOSE_ACTIVITY_REQUEST"
}

// See https://github.com/discord/discord-api-docs/blob/8ed15ce2a11beab51918a084cfd5450ea7a3a211/docs/topics/RPC.md#rpc-events
public enum EventType: String, Codable {
    case ready                 = "READY"
    case error                 = "ERROR"
    case guildStatus           = "GUILD_STATUS"
    case guildCreate           = "GUILD_CREATE"
    case channelCreate         = "CHANNEL_CREATE"
    case voiceChannelSelect    = "VOICE_CHANNEL_SELECT"
    case voiceStateCreate      = "VOICE_STATE_CREATE"
    case voiceStateUpdate      = "VOICE_STATE_UPDATE"
    case voiceStateDelete      = "VOICE_STATE_DELETE"
    case voiceSettingsUpdate   = "VOICE_SETTINGS_UPDATE"
    case voiceConnectionStatus = "VOICE_CONNECTION_STATUS"
    case speakingStart         = "SPEAKING_START"
    case speakingStop          = "SPEAKING_STOP"
    case messageCreate         = "MESSAGE_CREATE"
    case messageUpdate         = "MESSAGE_UPDATE"
    case messageDelete         = "MESSAGE_DELETE"
    case notificationCreate    = "NOTIFICATION_CREATE"
    case captureShortcutChange = "CAPTURE_SHORTCUT_CHANGE"
    case activityJoin          = "ACTIVITY_JOIN"
    case activitySpectate      = "ACTIVITY_SPECTATE"
    case activityJoinRequest   = "ACTIVITY_JOIN_REQUEST"
}

public enum VoiceState: String, Codable {
    case disconnected          = "DISCONNECTED"
    case awaitingEndpoint      = "AWAITING_ENDPOINT"
    case authenticating        = "AUTHENTICATING"
    case tcpConnecting         = "CONNECTING"
    case tcpConnected          = "CONNECTED"
    case voiceDisconnected     = "VOICE_DISCONNECTED"
    case voiceConnecting       = "VOICE_CONNECTING"
    case voiceConnected        = "VOICE_CONNECTED"
    case noRoute               = "NO_ROUTE"
    case iceChecking           = "ICE_CHECKING"
}

// See https://github.com/discord/discord-api-docs/blob/55cd3d71082e9dc31cbd007a6e74b1cd6a82beeb/docs/resources/User.md#user-flags
public enum UserFlag: Int, Codable {
    case none                      = 0
    case discordEmployee           = 1
    case partneredServerOwner      = 2
    case hypesquadEvents           = 4
    case bugHunterLevel1           = 8
    case houseBravery              = 64
    case houseBrilliance           = 128
    case houseBalance              = 256
    case earlySupporter            = 512
    case teamUser                  = 1024
    case bugHunterLevel2           = 16384
    case verifiedBot               = 65536
    case earlyVerifiedBotDeveloper = 131072
    case discordCertifiedModerator = 262144
    case botHttpInteractions       = 524288
    case activeDeveloper           = 4194304
}

// See https://github.com/discord/discord-api-docs/blob/55cd3d71082e9dc31cbd007a6e74b1cd6a82beeb/docs/resources/User.md#premium-types
public enum PremiumType: Int, Codable {
    case none         = 0
    case nitroClassic = 1
    case nitro        = 2
    case nitroBasic   = 3
}

// ------------------ //
// Internal constants //
// ------------------ //
// See https://github.com/discord/discord-rpc/blob/963aa9f3e5ce81a4682c6ca3d136cddda614db33/src/rpc_connection.h#L17
enum OPCode: UInt32 {
    case handshake = 0
    case frame     = 1
    case close     = 2
    case ping      = 3
    case pong      = 4
}

// See https://github.com/discord/discord-api-docs/blob/8ed15ce2a11beab51918a084cfd5450ea7a3a211/docs/topics/RPC.md#rpc-versions
let apiVersion = 1

// See https://github.com/discord/discord-rpc/blob/8e0c7848a6e7a95f9257dc6903d2d298352583e9/documentation/hard-mode.md#notes
let udsSuffixRange = 0 ... 9
