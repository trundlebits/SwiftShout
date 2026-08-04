//
//

import CShout

public class SwiftShout {
    public init() {
        shout_init()

        withUnsafeTemporaryAllocation(of: Int32.self, capacity: 3) { buffer in
            let base = buffer.baseAddress!
            let _ = shout_version(base, base + 1, base + 2)

            let versions = buffer.span
            print("Major: \(versions[0])")
            print("Minor: \(versions[1])")
            print("Patch: \(versions[2])")
        }
    }

    // Shuts down libshout for the whole process -- the counterpart to
    // shout_init(), same global scope. Not exercised by the test suite:
    // shout.h says nothing may be called afterwards, and Swift Testing
    // runs @Test functions in one shared process, so calling this here
    // would poison every other test sharing it.
    public static func shutdown() {
        shout_shutdown()
    }
}