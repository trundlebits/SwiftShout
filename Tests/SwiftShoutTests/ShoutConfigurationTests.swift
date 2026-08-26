import Testing
import CShout
@testable import SwiftShout

@Test func ApplyPopulatesConnectionGetters() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())

    var configuration = ShoutConfiguration()
    configuration.host = "icecast.example.com"
    configuration.port = 8000
    configuration.user = "source"
    configuration.password = "hackme"
    configuration.mount = "/stream"
    configuration.agent = "SwiftShout/0.1"
    configuration.protocol = .icy
    configuration.format = .mp3
    configuration.usage = .audio
    configuration.tls = .disabled
    configuration.isPublic = true
    configuration.contentLanguage = "en-US"
    configuration.nonblocking = .none

    try configuration.apply(to: connection)

    #expect(connection.host == "icecast.example.com")
    #expect(connection.port == 8000)
    #expect(connection.user == "source")
    #expect(connection.password == "hackme")
    #expect(connection.mount == "/stream")
    #expect(connection.agent == "SwiftShout/0.1")
    #expect(connection.protocol == .icy)
    #expect(connection.contentFormat.format == .mp3)
    #expect(connection.contentFormat.usage == .audio)
    #expect(connection.tls == .disabled)
    #expect(connection.isPublic == true)
    #expect(connection.contentLanguage == "en-US")
    #expect(connection.nonblocking == .none)
}

@Test func ApplyWritesAudioInfoAndMeta() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())

    let configuration = ShoutConfiguration(
        audioInfo: [.bitrate: "128", .channels: "2"],
        meta: [.name: "My Station", .genre: "Ambient"]
    )
    try configuration.apply(to: connection)

    #expect(connection.audioInfo(.bitrate) == "128")
    #expect(connection.audioInfo(.channels) == "2")
    #expect(connection.meta(.name) == "My Station")
    #expect(connection.meta(.genre) == "Ambient")
}

@Test func DefaultConfigurationLeavesLibshoutDefaultsInPlace() async throws {
    shout_init()
    // A fresh shout_t already carries libshout defaults (host "localhost",
    // user "source", ...); applying an empty configuration must not disturb
    // them or any unset field.
    let pristine = try #require(ShoutConnection())
    let configured = try #require(ShoutConnection())

    try ShoutConfiguration().apply(to: configured)

    #expect(configured.host == pristine.host)
    #expect(configured.user == pristine.user)
    #expect(configured.mount == pristine.mount)
    #expect(configured.port == pristine.port)
}

@Test func EquatableComparesAllFields() async throws {
    let base = ShoutConfiguration(host: "a", port: 8000, format: .mp3)
    #expect(base == ShoutConfiguration(host: "a", port: 8000, format: .mp3))

    var changed = base
    changed.mount = "/x"
    #expect(base != changed)

    var differentUsage = base
    differentUsage.usage = .visual
    #expect(base != differentUsage)
}

@Test func InitFromConfigurationBuildsConfiguredConnection() async throws {
    shout_init()

    let configuration = ShoutConfiguration(
        host: "127.0.0.1",
        port: 8000,
        user: "source",
        password: "hackme",
        mount: "/stream",
        format: .ogg
    )
    let connection = try ShoutConnection(configuration: configuration)

    #expect(connection.host == "127.0.0.1")
    #expect(connection.port == 8000)
    #expect(connection.mount == "/stream")
    #expect(connection.contentFormat.format == .ogg)
}

@Test func InitFromConfigurationRoundTripsThroughOpen() async throws {
    shout_init()

    let configuration = ShoutConfiguration(
        host: "127.0.0.1",
        port: 1,
        user: "source",
        password: "hackme",
        mount: "/test",
        format: .mp3
    )
    let connection = try ShoutConnection(configuration: configuration)

    let error = try #require(throws: ShoutError.self) { try connection.open() }
    #expect(error.code == .noConnect)
}
