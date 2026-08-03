import CShout

// Wraps SHOUT_TLS_xxxx.
struct TLSMode: RawRepresentable, Equatable, Sendable {
    let rawValue: Int32

    init(rawValue: Int32) {
        self.rawValue = rawValue
    }

    static let disabled = TLSMode(rawValue: SHOUT_TLS_DISABLED)
    static let auto = TLSMode(rawValue: SHOUT_TLS_AUTO)
    static let autoNoPlain = TLSMode(rawValue: SHOUT_TLS_AUTO_NO_PLAIN)
    static let rfc2818 = TLSMode(rawValue: SHOUT_TLS_RFC2818)
    static let rfc2817 = TLSMode(rawValue: SHOUT_TLS_RFC2817)
}

// Wraps SHOUT_PROTOCOL_xxxx.
struct StreamProtocol: RawRepresentable, Equatable, Sendable {
    let rawValue: UInt32

    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    static let http = StreamProtocol(rawValue: UInt32(SHOUT_PROTOCOL_HTTP))
    // Deprecated upstream, may be removed in future libshout versions -- do not use.
    static let xAudioCast = StreamProtocol(rawValue: UInt32(SHOUT_PROTOCOL_XAUDIOCAST))
    static let icy = StreamProtocol(rawValue: UInt32(SHOUT_PROTOCOL_ICY))
    static let roarAudio = StreamProtocol(rawValue: UInt32(SHOUT_PROTOCOL_ROARAUDIO))
}

// Wraps SHOUT_FORMAT_xxxx, as used by shout_get/set_content_format().
struct ContentFormat: RawRepresentable, Equatable, Sendable {
    let rawValue: UInt32

    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    static let ogg = ContentFormat(rawValue: UInt32(SHOUT_FORMAT_OGG))
    static let mp3 = ContentFormat(rawValue: UInt32(SHOUT_FORMAT_MP3))
    static let webm = ContentFormat(rawValue: UInt32(SHOUT_FORMAT_WEBM))
    static let matroska = ContentFormat(rawValue: UInt32(SHOUT_FORMAT_MATROSKA))
    static let text = ContentFormat(rawValue: UInt32(SHOUT_FORMAT_TEXT))
    // SHOUT_FORMAT_VORBIS is literally defined as SHOUT_FORMAT_OGG upstream.
    static let vorbis = ContentFormat.ogg
}

// Wraps SHOUT_USAGE_xxxx, a bit vector describing what a content format's
// substreams carry.
struct ContentUsage: OptionSet, Sendable {
    let rawValue: UInt32

    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    static let audio = ContentUsage(rawValue: SHOUT_USAGE_AUDIO)
    static let visual = ContentUsage(rawValue: SHOUT_USAGE_VISUAL)
    static let text = ContentUsage(rawValue: SHOUT_USAGE_TEXT)
    static let subtitle = ContentUsage(rawValue: SHOUT_USAGE_SUBTITLE)
    static let light = ContentUsage(rawValue: SHOUT_USAGE_LIGHT)
    static let ui = ContentUsage(rawValue: SHOUT_USAGE_UI)
    static let metadata = ContentUsage(rawValue: SHOUT_USAGE_METADATA)
    static let application = ContentUsage(rawValue: SHOUT_USAGE_APPLICATION)
    static let control = ContentUsage(rawValue: SHOUT_USAGE_CONTROL)
    static let complex = ContentUsage(rawValue: SHOUT_USAGE_COMPLEX)
    static let other = ContentUsage(rawValue: SHOUT_USAGE_OTHER)
    static let unknown = ContentUsage(rawValue: SHOUT_USAGE_UNKNOWN)
    static let threeD = ContentUsage(rawValue: SHOUT_USAGE_3D)
    static let fourD = ContentUsage(rawValue: SHOUT_USAGE_4D)
}

// Wraps SHOUT_BLOCKING_xxxx.
struct BlockingMode: RawRepresentable, Equatable, Sendable {
    let rawValue: UInt32

    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    static let full = BlockingMode(rawValue: UInt32(SHOUT_BLOCKING_FULL))
    static let none = BlockingMode(rawValue: UInt32(SHOUT_BLOCKING_NONE))
    static let `default` = BlockingMode(rawValue: UInt32(SHOUT_BLOCKING_DEFAULT))
}

// Wraps SHOUT_META_xxxx, the keys accepted by shout_get/set_meta().
struct MetaKey: RawRepresentable, Equatable, Sendable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    static let name = MetaKey(rawValue: SHOUT_META_NAME)
    static let url = MetaKey(rawValue: SHOUT_META_URL)
    static let genre = MetaKey(rawValue: SHOUT_META_GENRE)
    static let description = MetaKey(rawValue: SHOUT_META_DESCRIPTION)
    static let irc = MetaKey(rawValue: SHOUT_META_IRC)
    static let aim = MetaKey(rawValue: SHOUT_META_AIM)
    static let icq = MetaKey(rawValue: SHOUT_META_ICQ)
}

// Wraps SHOUT_AI_xxxx, the keys accepted by shout_get/set_audio_info().
struct AudioInfoKey: RawRepresentable, Equatable, Sendable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    static let bitrate = AudioInfoKey(rawValue: SHOUT_AI_BITRATE)
    static let samplerate = AudioInfoKey(rawValue: SHOUT_AI_SAMPLERATE)
    static let channels = AudioInfoKey(rawValue: SHOUT_AI_CHANNELS)
    static let quality = AudioInfoKey(rawValue: SHOUT_AI_QUALITY)
}
