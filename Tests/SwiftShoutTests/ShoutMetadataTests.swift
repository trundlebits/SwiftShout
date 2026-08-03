import Testing
import CShout
@testable import SwiftShout

@Test func InitShoutMetadata() async throws {
    shout_init()
    let metadata = ShoutMetadata()
    #expect(metadata != nil)
}

@Test func AddMetadataEntry() async throws {
    shout_init()
    let metadata = try #require(ShoutMetadata())
    #expect(metadata.add(name: "song", value: "Test Track") == SHOUTERR_SUCCESS)
}
