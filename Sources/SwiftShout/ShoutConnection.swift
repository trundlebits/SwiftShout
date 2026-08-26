import CShout

public final class ShoutConnection {
    private let handle: OpaquePointer

    public init?() {
        guard let handle = shout_new() else {
            return nil
        }
        self.handle = handle
    }

    deinit {
        shout_free(handle)
    }

    public var errorCode: Int32 {
        shout_get_errno(handle)
    }

    public var errorDescription: String {
        String(cString: shout_get_error(handle))
    }

    public var isConnected: Bool {
        shout_get_connected(handle) == SHOUTERR_CONNECTED
    }

    public var host: String? {
        shout_get_host(handle).map { String(cString: $0) }
    }

    @discardableResult
    public func setHost(_ host: String) -> Int32 {
        host.withCString { shout_set_host(handle, $0) }
    }

    public var port: UInt16 {
        shout_get_port(handle)
    }

    @discardableResult
    public func setPort(_ port: UInt16) -> Int32 {
        shout_set_port(handle, port)
    }

    public var user: String? {
        shout_get_user(handle).map { String(cString: $0) }
    }

    @discardableResult
    public func setUser(_ user: String) -> Int32 {
        user.withCString { shout_set_user(handle, $0) }
    }

    public var password: String? {
        shout_get_password(handle).map { String(cString: $0) }
    }

    @discardableResult
    public func setPassword(_ password: String) -> Int32 {
        password.withCString { shout_set_password(handle, $0) }
    }

    public var mount: String? {
        shout_get_mount(handle).map { String(cString: $0) }
    }

    @discardableResult
    public func setMount(_ mount: String) -> Int32 {
        mount.withCString { shout_set_mount(handle, $0) }
    }

    public func audioInfo(_ key: AudioInfoKey) -> String? {
        key.rawValue.withCString { keyPointer in
            shout_get_audio_info(handle, keyPointer).map { String(cString: $0) }
        }
    }

    @discardableResult
    public func setAudioInfo(_ key: AudioInfoKey, _ value: String) -> Int32 {
        key.rawValue.withCString { keyPointer in
            value.withCString { valuePointer in
                shout_set_audio_info(handle, keyPointer, valuePointer)
            }
        }
    }

    public func meta(_ key: MetaKey) -> String? {
        key.rawValue.withCString { keyPointer in
            shout_get_meta(handle, keyPointer).map { String(cString: $0) }
        }
    }

    @discardableResult
    public func setMeta(_ key: MetaKey, _ value: String) -> Int32 {
        key.rawValue.withCString { keyPointer in
            value.withCString { valuePointer in
                shout_set_meta(handle, keyPointer, valuePointer)
            }
        }
    }

    public var contentFormat: (format: ContentFormat, usage: ContentUsage) {
        withUnsafeTemporaryAllocation(of: UInt32.self, capacity: 2) { buffer in
            let base = buffer.baseAddress!
            let _ = shout_get_content_format(handle, base, base + 1, nil)
            let values = buffer.span
            return (ContentFormat(rawValue: values[0]), ContentUsage(rawValue: values[1]))
        }
    }

    @discardableResult
    public func setContentFormat(format: ContentFormat, usage: ContentUsage) -> Int32 {
        shout_set_content_format(handle, format.rawValue, usage.rawValue, nil)
    }

    public var agent: String? {
        shout_get_agent(handle).map { String(cString: $0) }
    }

    @discardableResult
    public func setAgent(_ agent: String) -> Int32 {
        agent.withCString { shout_set_agent(handle, $0) }
    }

    public var tls: TLSMode {
        TLSMode(rawValue: shout_get_tls(handle))
    }

    @discardableResult
    public func setTLS(_ mode: TLSMode) -> Int32 {
        shout_set_tls(handle, mode.rawValue)
    }

    public var caDirectory: String? {
        shout_get_ca_directory(handle).map { String(cString: $0) }
    }

    @discardableResult
    public func setCADirectory(_ directory: String) -> Int32 {
        directory.withCString { shout_set_ca_directory(handle, $0) }
    }

    public var caFile: String? {
        shout_get_ca_file(handle).map { String(cString: $0) }
    }

    @discardableResult
    public func setCAFile(_ file: String) -> Int32 {
        file.withCString { shout_set_ca_file(handle, $0) }
    }

    public var allowedCiphers: String? {
        shout_get_allowed_ciphers(handle).map { String(cString: $0) }
    }

    @discardableResult
    public func setAllowedCiphers(_ ciphers: String) -> Int32 {
        ciphers.withCString { shout_set_allowed_ciphers(handle, $0) }
    }

    public var clientCertificate: String? {
        shout_get_client_certificate(handle).map { String(cString: $0) }
    }

    @discardableResult
    public func setClientCertificate(_ certificate: String) -> Int32 {
        certificate.withCString { shout_set_client_certificate(handle, $0) }
    }

    public var isPublic: Bool {
        shout_get_public(handle) != 0
    }

    @discardableResult
    public func setPublic(_ isPublic: Bool) -> Int32 {
        shout_set_public(handle, isPublic ? 1 : 0)
    }

    public var contentLanguage: String? {
        shout_get_content_language(handle).map { String(cString: $0) }
    }

    @discardableResult
    public func setContentLanguage(_ contentLanguage: String) -> Int32 {
        contentLanguage.withCString { shout_set_content_language(handle, $0) }
    }

    public var `protocol`: StreamProtocol {
        StreamProtocol(rawValue: shout_get_protocol(handle))
    }

    @discardableResult
    public func setProtocol(_ protocol: StreamProtocol) -> Int32 {
        shout_set_protocol(handle, `protocol`.rawValue)
    }

    // Must be called before open() -- no switching back and forth midstream.
    public var nonblocking: BlockingMode {
        BlockingMode(rawValue: shout_get_nonblocking(handle))
    }

    @discardableResult
    public func setNonblocking(_ nonblocking: BlockingMode) -> Int32 {
        shout_set_nonblocking(handle, nonblocking.rawValue)
    }

    // Wraps a non-success libshout return code as a ShoutError, capturing the
    // handle's current error text now -- shout_get_error()'s string is only
    // valid until the next call on this handle.
    private func lastError(_ code: Int32) -> ShoutError {
        ShoutError(code: ShoutError.Code(rawValue: code), message: errorDescription)
    }

    // shout_open() is warn_unused_result in C: ignoring a failed connect
    // attempt is the kind of bug that attribute exists to catch, so this
    // throws rather than handing back a status code the caller can drop. In
    // nonblocking mode a thrown `.busy` means "connection in progress, call
    // open() again", not a hard failure.
    public func open() throws(ShoutError) {
        let result = shout_open(handle)
        guard result == SHOUTERR_SUCCESS else { throw lastError(result) }
    }

    @discardableResult
    public func close() -> Int32 {
        shout_close(handle)
    }

    // shout_send() is warn_unused_result in C, like shout_open(): a failed
    // send shouldn't be silently ignorable the way a setter's status can be,
    // so it throws. In nonblocking mode a thrown `.busy` means the write
    // queue is full -- retry after sync() / delay.
    //
    // The C call runs in a non-throwing closure and the throw happens after:
    // rethrows (which withUnsafeBufferPointer is) doesn't propagate a typed
    // throws, so a throwing closure here would erase ShoutError to any Error.
    public func send(_ data: Span<UInt8>) throws(ShoutError) {
        let result = data.withUnsafeBufferPointer { buffer in
            shout_send(handle, buffer.baseAddress, buffer.count)
        }
        guard result == SHOUTERR_SUCCESS else { throw lastError(result) }
    }

    // Overload for callers holding a plain [UInt8]. It can't route through
    // the Span overload above -- doing so inside withUnsafeBufferPointer
    // would make the closure throwing (see the note there) -- so it repeats
    // the small marshalling itself.
    public func send(_ data: [UInt8]) throws(ShoutError) {
        let result = data.withUnsafeBufferPointer { buffer in
            shout_send(handle, buffer.baseAddress, buffer.count)
        }
        guard result == SHOUTERR_SUCCESS else { throw lastError(result) }
    }

    // shout_send_raw() skips shout_send()'s format-specific timing parsing --
    // shout.h warns not to use this unless you know what you're doing. Like
    // shout_send(), it's warn_unused_result in C. Returns the number of bytes
    // written (which a nonblocking caller needs to spot a partial write);
    // throws when libshout reports a negative result.
    public func sendRaw(_ data: Span<UInt8>) throws(ShoutError) -> Int {
        let result = data.withUnsafeBufferPointer { buffer in
            shout_send_raw(handle, buffer.baseAddress, buffer.count)
        }
        guard result >= 0 else { throw lastError(Int32(result)) }
        return result
    }

    public func sendRaw(_ data: [UInt8]) throws(ShoutError) -> Int {
        let result = data.withUnsafeBufferPointer { buffer in
            shout_send_raw(handle, buffer.baseAddress, buffer.count)
        }
        guard result >= 0 else { throw lastError(Int32(result)) }
        return result
    }

    public func sync() {
        shout_sync(handle)
    }

    public var queueLength: Int {
        Int(shout_queuelen(handle))
    }

    public var delay: Int32 {
        shout_delay(handle)
    }

    // MP3/AAC streams only. shout_set_metadata_utf8() is warn_unused_result
    // in C, like shout_open() and shout_send(). Undocumented in shout.h but
    // verified experimentally: calling this before open() has succeeded
    // segfaults inside libshout itself -- only call this on an open connection.
    public func setMetadataUTF8(_ metadata: ShoutMetadata) throws(ShoutError) {
        let result = shout_set_metadata_utf8(handle, metadata.handle)
        guard result == SHOUTERR_SUCCESS else { throw lastError(result) }
    }
}
