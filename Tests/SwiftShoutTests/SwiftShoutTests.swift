import Testing
@testable import SwiftShout

@Test func InitSwiftShout() async throws {
    _ = SwiftShout()
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    // Swift Testing Documentation
    // https://swiftpackageindex.com/swiftlang/swift-testing/documentation
}

@Test func LibshoutVersion() async throws {
    let version = SwiftShout.libshoutVersion
    #expect(!version.isEmpty)
    #expect(version.first?.isNumber == true)   // e.g. "2.4.6"
}
