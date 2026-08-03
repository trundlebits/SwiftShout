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
}
