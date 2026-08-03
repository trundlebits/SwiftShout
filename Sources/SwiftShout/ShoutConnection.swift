import CShout

final class ShoutConnection {
    private let handle: OpaquePointer

    init?() {
        guard let handle = shout_new() else {
            return nil
        }
        self.handle = handle
    }

    deinit {
        shout_free(handle)
    }

    var errorCode: Int32 {
        shout_get_errno(handle)
    }

    var errorDescription: String {
        String(cString: shout_get_error(handle))
    }

    var isConnected: Bool {
        shout_get_connected(handle) == SHOUTERR_CONNECTED
    }

    var host: String? {
        shout_get_host(handle).map { String(cString: $0) }
    }

    @discardableResult
    func setHost(_ host: String) -> Int32 {
        host.withCString { shout_set_host(handle, $0) }
    }

    var port: UInt16 {
        shout_get_port(handle)
    }

    @discardableResult
    func setPort(_ port: UInt16) -> Int32 {
        shout_set_port(handle, port)
    }

    var user: String? {
        shout_get_user(handle).map { String(cString: $0) }
    }

    @discardableResult
    func setUser(_ user: String) -> Int32 {
        user.withCString { shout_set_user(handle, $0) }
    }

    var password: String? {
        shout_get_password(handle).map { String(cString: $0) }
    }

    @discardableResult
    func setPassword(_ password: String) -> Int32 {
        password.withCString { shout_set_password(handle, $0) }
    }

    var mount: String? {
        shout_get_mount(handle).map { String(cString: $0) }
    }

    @discardableResult
    func setMount(_ mount: String) -> Int32 {
        mount.withCString { shout_set_mount(handle, $0) }
    }

    var contentFormat: (format: UInt32, usage: UInt32) {
        withUnsafeTemporaryAllocation(of: UInt32.self, capacity: 2) { buffer in
            let base = buffer.baseAddress!
            let _ = shout_get_content_format(handle, base, base + 1, nil)
            let values = buffer.span
            return (values[0], values[1])
        }
    }

    @discardableResult
    func setContentFormat(format: UInt32, usage: UInt32) -> Int32 {
        shout_set_content_format(handle, format, usage, nil)
    }

    var agent: String? {
        shout_get_agent(handle).map { String(cString: $0) }
    }

    @discardableResult
    func setAgent(_ agent: String) -> Int32 {
        agent.withCString { shout_set_agent(handle, $0) }
    }

    // mode is one of SHOUT_TLS_xxxx.
    var tls: Int32 {
        shout_get_tls(handle)
    }

    @discardableResult
    func setTLS(_ mode: Int32) -> Int32 {
        shout_set_tls(handle, mode)
    }

    var caDirectory: String? {
        shout_get_ca_directory(handle).map { String(cString: $0) }
    }

    @discardableResult
    func setCADirectory(_ directory: String) -> Int32 {
        directory.withCString { shout_set_ca_directory(handle, $0) }
    }

    var caFile: String? {
        shout_get_ca_file(handle).map { String(cString: $0) }
    }

    @discardableResult
    func setCAFile(_ file: String) -> Int32 {
        file.withCString { shout_set_ca_file(handle, $0) }
    }

    var allowedCiphers: String? {
        shout_get_allowed_ciphers(handle).map { String(cString: $0) }
    }

    @discardableResult
    func setAllowedCiphers(_ ciphers: String) -> Int32 {
        ciphers.withCString { shout_set_allowed_ciphers(handle, $0) }
    }

    var clientCertificate: String? {
        shout_get_client_certificate(handle).map { String(cString: $0) }
    }

    @discardableResult
    func setClientCertificate(_ certificate: String) -> Int32 {
        certificate.withCString { shout_set_client_certificate(handle, $0) }
    }

    var isPublic: Bool {
        shout_get_public(handle) != 0
    }

    @discardableResult
    func setPublic(_ isPublic: Bool) -> Int32 {
        shout_set_public(handle, isPublic ? 1 : 0)
    }

    var contentLanguage: String? {
        shout_get_content_language(handle).map { String(cString: $0) }
    }

    @discardableResult
    func setContentLanguage(_ contentLanguage: String) -> Int32 {
        contentLanguage.withCString { shout_set_content_language(handle, $0) }
    }

    // nonblocking is one of SHOUT_BLOCKING_xxx. Must be called before open()
    // -- no switching back and forth midstream.
    var nonblocking: UInt32 {
        shout_get_nonblocking(handle)
    }

    @discardableResult
    func setNonblocking(_ nonblocking: UInt32) -> Int32 {
        shout_set_nonblocking(handle, nonblocking)
    }

    // shout_open() is warn_unused_result in C: ignoring a failed connect
    // attempt is the kind of bug that attribute exists to catch, so this
    // deliberately doesn't get @discardableResult like the setters above.
    func open() -> Int32 {
        shout_open(handle)
    }

    @discardableResult
    func close() -> Int32 {
        shout_close(handle)
    }

    // shout_send() is warn_unused_result in C, like shout_open(): a failed
    // send shouldn't be silently ignorable the way a setter's status can be.
    func send(_ data: Span<UInt8>) -> Int32 {
        data.withUnsafeBufferPointer { buffer in
            shout_send(handle, buffer.baseAddress, buffer.count)
        }
    }

    // Array's own `.span` needs a newer OS than this package's macOS 15
    // floor supports, which would otherwise force every caller holding a
    // plain [UInt8] through the withUnsafeBufferPointer dance themselves.
    // This overload does that once, here, instead.
    func send(_ data: [UInt8]) -> Int32 {
        data.withUnsafeBufferPointer { send($0.span) }
    }

    func sync() {
        shout_sync(handle)
    }

    var queueLength: Int {
        Int(shout_queuelen(handle))
    }

    var delay: Int32 {
        shout_delay(handle)
    }

    // MP3/AAC streams only. shout_set_metadata_utf8() is warn_unused_result
    // in C, like shout_open() and shout_send(). Undocumented in shout.h but
    // verified experimentally: calling this before open() has succeeded
    // segfaults inside libshout itself -- only call this on an open connection.
    func setMetadataUTF8(_ metadata: ShoutMetadata) -> Int32 {
        shout_set_metadata_utf8(handle, metadata.handle)
    }
}
