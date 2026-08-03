import Testing
import CShout
@testable import SwiftShout

@Test func InitShoutConnection() async throws {
    shout_init()
    let connection = ShoutConnection()
    #expect(connection != nil)
}
