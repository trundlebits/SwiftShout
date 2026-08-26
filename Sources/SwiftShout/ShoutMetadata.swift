import CShout

public final class ShoutMetadata {
    let handle: OpaquePointer

    public init?() {
        guard let handle = shout_metadata_new() else {
            return nil
        }
        self.handle = handle
    }

    deinit {
        shout_metadata_free(handle)
    }

    // shout_metadata_add() is warn_unused_result in C, like the actions on
    // ShoutConnection: a failed add shouldn't be silently ignorable, so it
    // throws. shout_metadata_t has no error-string accessor of its own (that
    // lives on shout_t), so the thrown ShoutError carries only the code --
    // shout.h documents just SHOUTERR_INSANE (bad argument) and
    // SHOUTERR_MALLOC here.
    public func add(name: String, value: String) throws(ShoutError) {
        let result = name.withCString { namePointer in
            value.withCString { valuePointer in
                shout_metadata_add(handle, namePointer, valuePointer)
            }
        }
        guard result == SHOUTERR_SUCCESS else {
            throw ShoutError(code: ShoutError.Code(rawValue: result), message: "")
        }
    }
}
