import Testing
import CShout
@testable import SwiftShout

@Test func ErrorCodeAndDescriptionAfterFailedOpen() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    connection.setHost("127.0.0.1")
    connection.setPort(1)
    connection.setMount("/test")
    connection.setContentFormat(format: .ogg, usage: .audio)
    _ = connection.open()

    #expect(connection.errorCode != SHOUTERR_SUCCESS)
    #expect(connection.errorDescription.isEmpty == false)
}

@Test func FreshConnectionIsUnconnected() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.isConnected == false)
}

@Test func GetAudioInfoForUnsetKeyIsNil() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.audioInfo(.samplerate) == nil)
}

@Test func GetMetaForUnsetKeyIsNil() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.meta(.genre) == nil)
}

@Test func InitShoutConnection() async throws {
    shout_init()
    let connection = ShoutConnection()
    #expect(connection != nil)
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
    connection.setContentFormat(format: .ogg, usage: .audio)

    #expect(connection.open() != SHOUTERR_SUCCESS)
    #expect(connection.isConnected == false)
    #expect(connection.close() != SHOUTERR_SUCCESS)
}

@Test func SendRawFailsWhenUnconnected() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    let data: [UInt8] = [0, 1, 2, 3]
    let result = data.withUnsafeBufferPointer { connection.sendRaw($0.span) }
    #expect(result < 0)
}

@Test func SendRawUInt8ArrayOverloadFailsWhenUnconnected() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    let data: [UInt8] = [0, 1, 2, 3]
    #expect(connection.sendRaw(data) < 0)
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

@Test func SetAndGetAgent() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setAgent("SwiftShout/0.1") == SHOUTERR_SUCCESS)
    #expect(connection.agent == "SwiftShout/0.1")
}

@Test func SetAndGetAllowedCiphers() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setAllowedCiphers("HIGH:!aNULL") == SHOUTERR_SUCCESS)
    #expect(connection.allowedCiphers == "HIGH:!aNULL")
}

@Test func SetAndGetAudioInfo() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setAudioInfo(.bitrate, "128") == SHOUTERR_SUCCESS)
    #expect(connection.audioInfo(.bitrate) == "128")
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

@Test func SetAndGetClientCertificate() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setClientCertificate("/etc/ssl/client.pem") == SHOUTERR_SUCCESS)
    #expect(connection.clientCertificate == "/etc/ssl/client.pem")
}

@Test func SetAndGetContentFormat() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setContentFormat(format: .ogg, usage: .audio) == SHOUTERR_SUCCESS)
    let readBack = connection.contentFormat
    #expect(readBack.format == .ogg)
    #expect(readBack.usage == .audio)
}

@Test func SetAndGetContentLanguage() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setContentLanguage("en-US") == SHOUTERR_SUCCESS)
    #expect(connection.contentLanguage == "en-US")
}

@Test func SetAndGetHost() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setHost("icecast.example.com") == SHOUTERR_SUCCESS)
    #expect(connection.host == "icecast.example.com")
}

@Test func SetAndGetMeta() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setMeta(.name, "My Station") == SHOUTERR_SUCCESS)
    #expect(connection.meta(.name) == "My Station")
}

@Test func SetAndGetMount() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setMount("/stream") == SHOUTERR_SUCCESS)
    #expect(connection.mount == "/stream")
}

@Test func SetAndGetNonblocking() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setNonblocking(.none) == SHOUTERR_SUCCESS)
    #expect(connection.nonblocking == .none)
}

@Test func SetAndGetPassword() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setPassword("hackme") == SHOUTERR_SUCCESS)
    #expect(connection.password == "hackme")
}

@Test func SetAndGetPort() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setPort(8000) == SHOUTERR_SUCCESS)
    #expect(connection.port == 8000)
}

@Test func SetAndGetProtocol() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setProtocol(.icy) == SHOUTERR_SUCCESS)
    #expect(connection.protocol == .icy)
}

@Test func SetAndGetPublic() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setPublic(true) == SHOUTERR_SUCCESS)
    #expect(connection.isPublic == true)
    #expect(connection.setPublic(false) == SHOUTERR_SUCCESS)
    #expect(connection.isPublic == false)
}

@Test func SetAndGetTLS() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setTLS(.disabled) == SHOUTERR_SUCCESS)
    #expect(connection.tls == .disabled)
}

@Test func SetAndGetUser() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    #expect(connection.setUser("source") == SHOUTERR_SUCCESS)
    #expect(connection.user == "source")
}

// setMetadataUTF8() is deliberately not exercised here: calling it on a
// handle that has never been through open() segfaults inside libshout
// itself (verified experimentally -- this precondition isn't documented
// in shout.h). Covering it needs a real, opened connection, same
// constraint as OpenFailsWithoutReachableServer above.
