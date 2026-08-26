//
//

import CShout

public class SwiftShout {
    public init() {
        shout_init()
    }

    // libshout's version as one string, e.g. "2.4.6". shout.h documents the
    // return value as a static string, so it is never null; the int
    // out-parameters are optional and we don't need them.
    public static var libshoutVersion: String {
        String(cString: shout_version(nil, nil, nil))
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