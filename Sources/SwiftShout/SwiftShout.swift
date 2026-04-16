//
//

import CShout

class SwiftShout {
    init() {
        shout_init()
        // https://medium.com/@maxches/advanced-memory-management-with-unsafe-swift-f34d5bfbd78f
        let major = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        let minor = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        let patch = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        let _ = shout_version(major, minor, patch)
        // let shoutVersion = shout_version(major, minor, patch)
        // print("Shout version: \(shoutVersion!)")

        // https://www.kodeco.com/7181017-unsafe-swift-using-pointers-and-interacting-with-c/page/4
        print("Major: \(major.pointee)")
        print("Minor: \(minor.pointee)")
        print("Patch: \(patch.pointee)")
    }
}