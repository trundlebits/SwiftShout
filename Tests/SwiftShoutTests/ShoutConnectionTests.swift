import Testing
import CShout
@testable import SwiftShout

@Test func InitShoutConnection() async throws {
    shout_init()
    let connection = ShoutConnection()
    #expect(connection != nil)
}

@Test func FreshConnectionIsUnconnected() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.isConnected == false)
}

@Test func SetAndGetHost() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setHost("icecast.example.com") == SHOUTERR_SUCCESS)
    #expect(connection.host == "icecast.example.com")
}

@Test func SetAndGetPort() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setPort(8000) == SHOUTERR_SUCCESS)
    #expect(connection.port == 8000)
}

@Test func SetAndGetUser() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setUser("source") == SHOUTERR_SUCCESS)
    #expect(connection.user == "source")
}

@Test func SetAndGetPassword() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setPassword("hackme") == SHOUTERR_SUCCESS)
    #expect(connection.password == "hackme")
}

@Test func SetAndGetMount() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setMount("/stream") == SHOUTERR_SUCCESS)
    #expect(connection.mount == "/stream")
}

@Test func SetAndGetContentFormat() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    let format = UInt32(SHOUT_FORMAT_OGG)
    let usage = SHOUT_USAGE_AUDIO
    #expect(connection.setContentFormat(format: format, usage: usage) == SHOUTERR_SUCCESS)
    let readBack = connection.contentFormat
    #expect(readBack.format == format)
    #expect(readBack.usage == usage)
}

@Test func OpenFailsWithoutReachableServer() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    // Port 1 (TCPMUX) on loopback: nothing listens there, so the connect
    // attempt fails fast (connection refused) instead of needing a real
    // Icecast server or risking a slow timeout against an unreachable host.
    connection.setHost("127.0.0.1")
    connection.setPort(1)
    connection.setMount("/test")
    connection.setContentFormat(format: UInt32(SHOUT_FORMAT_OGG), usage: SHOUT_USAGE_AUDIO)

    #expect(connection.open() != SHOUTERR_SUCCESS)
    #expect(connection.isConnected == false)
    connection.close()
}
