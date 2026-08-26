import CShout

/// A value describing everything a `ShoutConnection` needs before `open()`:
/// one `Sendable`, `Equatable` struct in place of a dozen-plus individual
/// setter calls.
///
/// Most fields are optional: an unset (`nil`) one, or an empty dictionary,
/// leaves libshout's own default in place. `nonblocking` is the exception --
/// it has no "unset" and is always applied. Build one and hand it to
/// `ShoutConnection(configuration:)`, or `apply(to:)` it to a connection you
/// already have.
public struct ShoutConfiguration: Sendable, Equatable {
    public var host: String?
    public var port: UInt16?
    public var user: String?
    public var password: String?
    public var mount: String?
    public var agent: String?
    public var `protocol`: StreamProtocol?

    /// The content format. `usage` is applied alongside it, and ignored while
    /// this is `nil`.
    public var format: ContentFormat?
    /// Substream usage passed with `format`; defaults to `.audio`.
    public var usage: ContentUsage

    public var tls: TLSMode?
    public var caDirectory: String?
    public var caFile: String?
    public var allowedCiphers: String?
    public var clientCertificate: String?
    public var isPublic: Bool?
    public var contentLanguage: String?

    /// Blocking mode, applied on every `apply(to:)` (libshout requires it be
    /// set before `open()`, which is when a configuration is applied).
    ///
    /// Not optional: `BlockingMode.none` would collide with `Optional.none`, so
    /// `config.nonblocking = .none` would silently mean "unset". `.default`
    /// tells libshout to use its own default (blocking).
    public var nonblocking: BlockingMode

    /// `SHOUT_AI_*` audio-info entries (bitrate, samplerate, ...).
    public var audioInfo: [AudioInfoKey: String]
    /// `SHOUT_META_*` per-mount metadata (name, url, genre, ...). Distinct from
    /// the in-stream MP3/AAC metadata carried by `ShoutMetadata`.
    public var meta: [MetaKey: String]

    public init(
        host: String? = nil,
        port: UInt16? = nil,
        user: String? = nil,
        password: String? = nil,
        mount: String? = nil,
        agent: String? = nil,
        protocol streamProtocol: StreamProtocol? = nil,
        format: ContentFormat? = nil,
        usage: ContentUsage = .audio,
        tls: TLSMode? = nil,
        caDirectory: String? = nil,
        caFile: String? = nil,
        allowedCiphers: String? = nil,
        clientCertificate: String? = nil,
        isPublic: Bool? = nil,
        contentLanguage: String? = nil,
        nonblocking: BlockingMode = .default,
        audioInfo: [AudioInfoKey: String] = [:],
        meta: [MetaKey: String] = [:]
    ) {
        self.host = host
        self.port = port
        self.user = user
        self.password = password
        self.mount = mount
        self.agent = agent
        self.`protocol` = streamProtocol
        self.format = format
        self.usage = usage
        self.tls = tls
        self.caDirectory = caDirectory
        self.caFile = caFile
        self.allowedCiphers = allowedCiphers
        self.clientCertificate = clientCertificate
        self.isPublic = isPublic
        self.contentLanguage = contentLanguage
        self.nonblocking = nonblocking
        self.audioInfo = audioInfo
        self.meta = meta
    }

    // Applies each set field through ShoutConnection's setters, throwing the
    // first ShoutError any of them reports. Fields left nil -- and empty
    // dictionaries -- are skipped, leaving libshout's default untouched.
    public func apply(to connection: ShoutConnection) throws(ShoutError) {
        func set(_ status: Int32) throws(ShoutError) {
            try connection.checked(status)
        }

        if let host { try set(connection.setHost(host)) }
        if let port { try set(connection.setPort(port)) }
        if let user { try set(connection.setUser(user)) }
        if let password { try set(connection.setPassword(password)) }
        if let mount { try set(connection.setMount(mount)) }
        if let agent { try set(connection.setAgent(agent)) }
        if let `protocol` { try set(connection.setProtocol(`protocol`)) }
        if let format { try set(connection.setContentFormat(format: format, usage: usage)) }
        if let tls { try set(connection.setTLS(tls)) }
        if let caDirectory { try set(connection.setCADirectory(caDirectory)) }
        if let caFile { try set(connection.setCAFile(caFile)) }
        if let allowedCiphers { try set(connection.setAllowedCiphers(allowedCiphers)) }
        if let clientCertificate { try set(connection.setClientCertificate(clientCertificate)) }
        if let isPublic { try set(connection.setPublic(isPublic)) }
        if let contentLanguage { try set(connection.setContentLanguage(contentLanguage)) }
        try set(connection.setNonblocking(nonblocking))
        for (key, value) in audioInfo { try set(connection.setAudioInfo(key, value)) }
        for (key, value) in meta { try set(connection.setMeta(key, value)) }
    }
}
