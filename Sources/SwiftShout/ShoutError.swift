import CShout

/// A failure reported by libshout: the `SHOUTERR_xxxx` code paired with the
/// description libshout gave for it.
///
/// libshout's own error string (`shout_get_error()`) is only valid until the
/// next call on the same handle, so `message` is captured when the error is
/// raised rather than fetched lazily.
public struct ShoutError: Error, Equatable, Sendable, CustomStringConvertible {

    /// One of libshout's `SHOUTERR_xxxx` codes. `SHOUTERR_SUCCESS` is not a
    /// failure and never appears here.
    public struct Code: RawRepresentable, Equatable, Sendable, CustomStringConvertible {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        public static let insane = Code(rawValue: SHOUTERR_INSANE)
        public static let noConnect = Code(rawValue: SHOUTERR_NOCONNECT)
        public static let noLogin = Code(rawValue: SHOUTERR_NOLOGIN)
        public static let socket = Code(rawValue: SHOUTERR_SOCKET)
        public static let malloc = Code(rawValue: SHOUTERR_MALLOC)
        public static let metadata = Code(rawValue: SHOUTERR_METADATA)
        public static let connected = Code(rawValue: SHOUTERR_CONNECTED)
        public static let unconnected = Code(rawValue: SHOUTERR_UNCONNECTED)
        public static let unsupported = Code(rawValue: SHOUTERR_UNSUPPORTED)
        public static let busy = Code(rawValue: SHOUTERR_BUSY)
        public static let notTLS = Code(rawValue: SHOUTERR_NOTLS)
        public static let tlsBadCert = Code(rawValue: SHOUTERR_TLSBADCERT)
        public static let retry = Code(rawValue: SHOUTERR_RETRY)

        // Mirrors the one-line explanations in shout.h. Used as a fallback
        // message when libshout has no per-handle error string to offer --
        // e.g. failures from shout_metadata_add(), which acts on a
        // shout_metadata_t rather than a shout_t.
        public var description: String {
            switch self {
            case .insane: "nonsensical arguments"
            case .noConnect: "couldn't connect"
            case .noLogin: "login failed"
            case .socket: "socket error"
            case .malloc: "out of memory"
            case .metadata: "metadata error"
            case .connected: "cannot set parameter while connected"
            case .unconnected: "not connected"
            case .unsupported: "libshout doesn't support the requested option"
            case .busy: "resource is busy, try again later"
            case .notTLS: "TLS requested but not supported by peer"
            case .tlsBadCert: "TLS connection cannot be established: bad certificate"
            case .retry: "retry last operation"
            default: "libshout error \(rawValue)"
            }
        }
    }

    /// The `SHOUTERR_xxxx` code libshout returned.
    public let code: Code

    /// libshout's description of the failure, captured when it was raised.
    /// Empty when libshout had no per-handle string to give; read
    /// ``description`` for a message that always has content.
    public let message: String

    public init(code: Code, message: String) {
        self.code = code
        self.message = message
    }

    public var description: String {
        message.isEmpty ? code.description : message
    }
}
