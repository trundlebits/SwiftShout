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
}
