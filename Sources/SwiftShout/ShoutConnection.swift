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

    func audioInfo(_ key: AudioInfoKey) -> String? {
        key.rawValue.withCString { keyPointer in
            shout_get_audio_info(handle, keyPointer).map { String(cString: $0) }
        }
    }

    @discardableResult
    func setAudioInfo(_ key: AudioInfoKey, _ value: String) -> Int32 {
        key.rawValue.withCString { keyPointer in
            value.withCString { valuePointer in
                shout_set_audio_info(handle, keyPointer, valuePointer)
            }
        }
    }

    func meta(_ key: MetaKey) -> String? {
        key.rawValue.withCString { keyPointer in
            shout_get_meta(handle, keyPointer).map { String(cString: $0) }
        }
    }

    @discardableResult
    func setMeta(_ key: MetaKey, _ value: String) -> Int32 {
        key.rawValue.withCString { keyPointer in
            value.withCString { valuePointer in
                shout_set_meta(handle, keyPointer, valuePointer)
            }
        }
    }

    var contentFormat: (format: ContentFormat, usage: ContentUsage) {
        withUnsafeTemporaryAllocation(of: UInt32.self, capacity: 2) { buffer in
            let base = buffer.baseAddress!
            let _ = shout_get_content_format(handle, base, base + 1, nil)
            let values = buffer.span
            return (ContentFormat(rawValue: values[0]), ContentUsage(rawValue: values[1]))
        }
    }

    @discardableResult
    func setContentFormat(format: ContentFormat, usage: ContentUsage) -> Int32 {
        shout_set_content_format(handle, format.rawValue, usage.rawValue, nil)
    }

    var agent: String? {
        shout_get_agent(handle).map { String(cString: $0) }
    }

    @discardableResult
    func setAgent(_ agent: String) -> Int32 {
        agent.withCString { shout_set_agent(handle, $0) }
    }

    var tls: TLSMode {
        TLSMode(rawValue: shout_get_tls(handle))
    }

    @discardableResult
    func setTLS(_ mode: TLSMode) -> Int32 {
        shout_set_tls(handle, mode.rawValue)
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

    var `protocol`: StreamProtocol {
        StreamProtocol(rawValue: shout_get_protocol(handle))
    }

    @discardableResult
    func setProtocol(_ protocol: StreamProtocol) -> Int32 {
        shout_set_protocol(handle, `protocol`.rawValue)
    }

    // Must be called before open() -- no switching back and forth midstream.
    var nonblocking: BlockingMode {
        BlockingMode(rawValue: shout_get_nonblocking(handle))
    }

    @discardableResult
    func setNonblocking(_ nonblocking: BlockingMode) -> Int32 {
        shout_set_nonblocking(handle, nonblocking.rawValue)
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

    // shout_send_raw() skips shout_send()'s format-specific timing parsing --
    // shout.h warns not to use this unless you know what you're doing. Like
    // shout_send(), it's warn_unused_result in C, so no @discardableResult.
    // Returns the number of bytes written, or a negative SHOUTERR_xxx on error.
    func sendRaw(_ data: Span<UInt8>) -> Int {
        data.withUnsafeBufferPointer { buffer in
            shout_send_raw(handle, buffer.baseAddress, buffer.count)
        }
    }

    func sendRaw(_ data: [UInt8]) -> Int {
        data.withUnsafeBufferPointer { sendRaw($0.span) }
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
