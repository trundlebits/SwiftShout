import Testing
import CShout
@testable import SwiftShout

@Test func AddMetadataEntry() async throws {
    shout_init()
    let metadata = try #require(ShoutMetadata())
    try metadata.add(name: "song", value: "Test Track")
}

@Test func AddMetadataEntryOverwritesPreviousValue() async throws {
    shout_init()
    let metadata = try #require(ShoutMetadata())
    try metadata.add(name: "song", value: "First Track")
    try metadata.add(name: "song", value: "Second Track")
}

@Test func AddMetadataEntryWithEmptyValue() async throws {
    shout_init()
    let metadata = try #require(ShoutMetadata())
    try metadata.add(name: "song", value: "")
}

@Test func AddMultipleMetadataEntries() async throws {
    shout_init()
    let metadata = try #require(ShoutMetadata())
    try metadata.add(name: "song", value: "Test Track")
    try metadata.add(name: "title", value: "Test Title")
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
    try first.add(name: "song", value: "First Track")
    try second.add(name: "song", value: "Second Track")
}
