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

@Test func SetAndGetMeta() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setMeta(SHOUT_META_NAME, "My Station") == SHOUTERR_SUCCESS)
    #expect(connection.meta(SHOUT_META_NAME) == "My Station")
}

@Test func GetMetaForUnsetKeyIsNil() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.meta(SHOUT_META_GENRE) == nil)
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

@Test func SetAndGetAgent() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setAgent("SwiftShout/0.1") == SHOUTERR_SUCCESS)
    #expect(connection.agent == "SwiftShout/0.1")
}

@Test func SetAndGetTLS() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setTLS(SHOUT_TLS_DISABLED) == SHOUTERR_SUCCESS)
    #expect(connection.tls == SHOUT_TLS_DISABLED)
}

@Test func SetAndGetCADirectory() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setCADirectory("/etc/ssl/certs") == SHOUTERR_SUCCESS)
    #expect(connection.caDirectory == "/etc/ssl/certs")
}

@Test func SetAndGetCAFile() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setCAFile("/etc/ssl/cert.pem") == SHOUTERR_SUCCESS)
    #expect(connection.caFile == "/etc/ssl/cert.pem")
}

@Test func SetAndGetAllowedCiphers() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setAllowedCiphers("HIGH:!aNULL") == SHOUTERR_SUCCESS)
    #expect(connection.allowedCiphers == "HIGH:!aNULL")
}

@Test func SetAndGetClientCertificate() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setClientCertificate("/etc/ssl/client.pem") == SHOUTERR_SUCCESS)
    #expect(connection.clientCertificate == "/etc/ssl/client.pem")
}

@Test func SetAndGetPublic() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setPublic(true) == SHOUTERR_SUCCESS)
    #expect(connection.isPublic == true)
    #expect(connection.setPublic(false) == SHOUTERR_SUCCESS)
    #expect(connection.isPublic == false)
}

@Test func SetAndGetContentLanguage() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setContentLanguage("en-US") == SHOUTERR_SUCCESS)
    #expect(connection.contentLanguage == "en-US")
}

@Test func SetAndGetNonblocking() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    let nonblocking = UInt32(SHOUT_BLOCKING_NONE)
    #expect(connection.setNonblocking(nonblocking) == SHOUTERR_SUCCESS)
    #expect(connection.nonblocking == nonblocking)
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

@Test func SendSyncAndQueueIntrospectionWhenUnconnected() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())

    // Like OpenFailsWithoutReachableServer, this exercises the wrapper's
    // plumbing (byte marshaling through Span, sync/queue introspection)
    // without needing a live Icecast server -- sending on an unconnected
    // handle should fail, not crash.
    let data: [UInt8] = [0, 1, 2, 3]
    let result = data.withUnsafeBufferPointer { connection.send($0.span) }
    #expect(result != SHOUTERR_SUCCESS)

    connection.sync()
    _ = connection.queueLength
    _ = connection.delay
}

@Test func SendUInt8ArrayOverloadFailsWhenUnconnected() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    let data: [UInt8] = [0, 1, 2, 3]
    #expect(connection.send(data) != SHOUTERR_SUCCESS)
}

// setMetadataUTF8() is deliberately not exercised here: calling it on a
// handle that has never been through open() segfaults inside libshout
// itself (verified experimentally -- this precondition isn't documented
// in shout.h). Covering it needs a real, opened connection, same
// constraint as OpenFailsWithoutReachableServer above.
