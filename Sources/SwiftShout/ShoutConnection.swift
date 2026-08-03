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
}
