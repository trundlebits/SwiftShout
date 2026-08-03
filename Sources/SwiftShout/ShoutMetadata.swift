import CShout

final class ShoutMetadata {
    let handle: OpaquePointer

    init?() {
        guard let handle = shout_metadata_new() else {
            return nil
        }
        self.handle = handle
    }

    deinit {
        shout_metadata_free(handle)
    }

    // shout_metadata_add() is warn_unused_result in C, like the actions on
    // ShoutConnection: a failed add shouldn't be silently ignorable.
    func add(name: String, value: String) -> Int32 {
        name.withCString { namePointer in
            value.withCString { valuePointer in
                shout_metadata_add(handle, namePointer, valuePointer)
            }
        }
    }
}
