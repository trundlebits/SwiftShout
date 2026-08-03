//
//

import CShout

class SwiftShout {
    init() {
        shout_init()

        withUnsafeTemporaryAllocation(of: Int32.self, capacity: 3) { buffer in
            let base = buffer.baseAddress!
            // https://medium.com/@maxches/advanced-memory-management-with-unsafe-swift-f34d5bfbd78f
            let _ = shout_version(base, base + 1, base + 2)

            // https://www.kodeco.com/7181017-unsafe-swift-using-pointers-and-interacting-with-c/page/4
            let versions = buffer.span
            print("Major: \(versions[0])")
            print("Minor: \(versions[1])")
            print("Patch: \(versions[2])")
        }
    }
}