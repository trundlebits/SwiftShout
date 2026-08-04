import CShout

// Wraps SHOUT_TLS_xxxx.
public struct TLSMode: RawRepresentable, Equatable, Sendable {
    public let rawValue: Int32

    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }

    public static let disabled = TLSMode(rawValue: SHOUT_TLS_DISABLED)
    public static let auto = TLSMode(rawValue: SHOUT_TLS_AUTO)
    public static let autoNoPlain = TLSMode(rawValue: SHOUT_TLS_AUTO_NO_PLAIN)
    public static let rfc2818 = TLSMode(rawValue: SHOUT_TLS_RFC2818)
    public static let rfc2817 = TLSMode(rawValue: SHOUT_TLS_RFC2817)
}

// Wraps SHOUT_PROTOCOL_xxxx.
public struct StreamProtocol: RawRepresentable, Equatable, Sendable {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let http = StreamProtocol(rawValue: UInt32(SHOUT_PROTOCOL_HTTP))
    // Deprecated upstream, may be removed in future libshout versions -- do not use.
    public static let xAudioCast = StreamProtocol(rawValue: UInt32(SHOUT_PROTOCOL_XAUDIOCAST))
    public static let icy = StreamProtocol(rawValue: UInt32(SHOUT_PROTOCOL_ICY))
    public static let roarAudio = StreamProtocol(rawValue: UInt32(SHOUT_PROTOCOL_ROARAUDIO))
}

// Wraps SHOUT_FORMAT_xxxx, as used by shout_get/set_content_format().
public struct ContentFormat: RawRepresentable, Equatable, Sendable {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let ogg = ContentFormat(rawValue: UInt32(SHOUT_FORMAT_OGG))
    public static let mp3 = ContentFormat(rawValue: UInt32(SHOUT_FORMAT_MP3))
    public static let webm = ContentFormat(rawValue: UInt32(SHOUT_FORMAT_WEBM))
    public static let matroska = ContentFormat(rawValue: UInt32(SHOUT_FORMAT_MATROSKA))
    public static let text = ContentFormat(rawValue: UInt32(SHOUT_FORMAT_TEXT))
    // SHOUT_FORMAT_VORBIS is literally defined as SHOUT_FORMAT_OGG upstream.
    public static let vorbis = ContentFormat.ogg
}

// Wraps SHOUT_USAGE_xxxx, a bit vector describing what a content format's
// substreams carry.
public struct ContentUsage: OptionSet, Sendable {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let audio = ContentUsage(rawValue: SHOUT_USAGE_AUDIO)
    public static let visual = ContentUsage(rawValue: SHOUT_USAGE_VISUAL)
    public static let text = ContentUsage(rawValue: SHOUT_USAGE_TEXT)
    public static let subtitle = ContentUsage(rawValue: SHOUT_USAGE_SUBTITLE)
    public static let light = ContentUsage(rawValue: SHOUT_USAGE_LIGHT)
    public static let ui = ContentUsage(rawValue: SHOUT_USAGE_UI)
    public static let metadata = ContentUsage(rawValue: SHOUT_USAGE_METADATA)
    public static let application = ContentUsage(rawValue: SHOUT_USAGE_APPLICATION)
    public static let control = ContentUsage(rawValue: SHOUT_USAGE_CONTROL)
    public static let complex = ContentUsage(rawValue: SHOUT_USAGE_COMPLEX)
    public static let other = ContentUsage(rawValue: SHOUT_USAGE_OTHER)
    public static let unknown = ContentUsage(rawValue: SHOUT_USAGE_UNKNOWN)
    public static let threeD = ContentUsage(rawValue: SHOUT_USAGE_3D)
    public static let fourD = ContentUsage(rawValue: SHOUT_USAGE_4D)
}

// Wraps SHOUT_BLOCKING_xxxx.
public struct BlockingMode: RawRepresentable, Equatable, Sendable {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let full = BlockingMode(rawValue: UInt32(SHOUT_BLOCKING_FULL))
    public static let none = BlockingMode(rawValue: UInt32(SHOUT_BLOCKING_NONE))
    public static let `default` = BlockingMode(rawValue: UInt32(SHOUT_BLOCKING_DEFAULT))
}

// Wraps SHOUT_META_xxxx, the keys accepted by shout_get/set_meta().
public struct MetaKey: RawRepresentable, Equatable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let name = MetaKey(rawValue: SHOUT_META_NAME)
    public static let url = MetaKey(rawValue: SHOUT_META_URL)
    public static let genre = MetaKey(rawValue: SHOUT_META_GENRE)
    public static let description = MetaKey(rawValue: SHOUT_META_DESCRIPTION)
    public static let irc = MetaKey(rawValue: SHOUT_META_IRC)
    public static let aim = MetaKey(rawValue: SHOUT_META_AIM)
    public static let icq = MetaKey(rawValue: SHOUT_META_ICQ)
}

// Wraps SHOUT_AI_xxxx, the keys accepted by shout_get/set_audio_info().
public struct AudioInfoKey: RawRepresentable, Equatable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let bitrate = AudioInfoKey(rawValue: SHOUT_AI_BITRATE)
    public static let samplerate = AudioInfoKey(rawValue: SHOUT_AI_SAMPLERATE)
    public static let channels = AudioInfoKey(rawValue: SHOUT_AI_CHANNELS)
    public static let quality = AudioInfoKey(rawValue: SHOUT_AI_QUALITY)
}
