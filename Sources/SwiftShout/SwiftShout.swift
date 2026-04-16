//
//

import CShout

class SwiftShout {
    init() {
        shout_init()
        let shoutVersion = shout_version(UnsafeMutablePointer<Int32>!, UnsafeMutablePointer<Int32>!, UnsafeMutablePointer<Int32>!)
    }
}