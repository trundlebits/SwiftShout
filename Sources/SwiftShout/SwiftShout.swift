//
//

import CShout

class SwiftShout {
    init() {
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
}