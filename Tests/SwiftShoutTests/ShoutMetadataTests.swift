import Testing
import CShout
@testable import SwiftShout

@Test func AddMetadataEntry() async throws {
    shout_init()
    let metadata = try #require(ShoutMetadata())
    #expect(metadata.add(name: "song", value: "Test Track") == SHOUTERR_SUCCESS)
}

@Test func AddMetadataEntryOverwritesPreviousValue() async throws {
    shout_init()
    let metadata = try #require(ShoutMetadata())
    #expect(metadata.add(name: "song", value: "First Track") == SHOUTERR_SUCCESS)
    #expect(metadata.add(name: "song", value: "Second Track") == SHOUTERR_SUCCESS)
}

@Test func AddMetadataEntryWithEmptyValue() async throws {
    shout_init()
    let metadata = try #require(ShoutMetadata())
    #expect(metadata.add(name: "song", value: "") == SHOUTERR_SUCCESS)
}

@Test func AddMultipleMetadataEntries() async throws {
    shout_init()
    let metadata = try #require(ShoutMetadata())
    #expect(metadata.add(name: "song", value: "Test Track") == SHOUTERR_SUCCESS)
    #expect(metadata.add(name: "title", value: "Test Title") == SHOUTERR_SUCCESS)
}

@Test func InitShoutMetadata() async throws {
    shout_init()
    let metadata = ShoutMetadata()
    #expect(metadata != nil)
}

@Test func MultipleShoutMetadataInstancesAreIndependent() async throws {
    shout_init()
    let first = try #require(ShoutMetadata())
    let second = try #require(ShoutMetadata())
    #expect(first.add(name: "song", value: "First Track") == SHOUTERR_SUCCESS)
    #expect(second.add(name: "song", value: "Second Track") == SHOUTERR_SUCCESS)
}
