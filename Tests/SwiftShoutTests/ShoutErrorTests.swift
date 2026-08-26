import Testing
import CShout
@testable import SwiftShout

@Test func CodeRawValuesMatchLibshout() async throws {
    #expect(ShoutError.Code.insane.rawValue == SHOUTERR_INSANE)
    #expect(ShoutError.Code.noConnect.rawValue == SHOUTERR_NOCONNECT)
    #expect(ShoutError.Code.noLogin.rawValue == SHOUTERR_NOLOGIN)
    #expect(ShoutError.Code.socket.rawValue == SHOUTERR_SOCKET)
    #expect(ShoutError.Code.malloc.rawValue == SHOUTERR_MALLOC)
    #expect(ShoutError.Code.metadata.rawValue == SHOUTERR_METADATA)
    #expect(ShoutError.Code.connected.rawValue == SHOUTERR_CONNECTED)
    #expect(ShoutError.Code.unconnected.rawValue == SHOUTERR_UNCONNECTED)
    #expect(ShoutError.Code.unsupported.rawValue == SHOUTERR_UNSUPPORTED)
    #expect(ShoutError.Code.busy.rawValue == SHOUTERR_BUSY)
    #expect(ShoutError.Code.notTLS.rawValue == SHOUTERR_NOTLS)
    #expect(ShoutError.Code.tlsBadCert.rawValue == SHOUTERR_TLSBADCERT)
    #expect(ShoutError.Code.retry.rawValue == SHOUTERR_RETRY)
}

@Test func DescriptionFallsBackToCodeWhenMessageEmpty() async throws {
    let error = ShoutError(code: .malloc, message: "")
    #expect(error.description == ShoutError.Code.malloc.description)
    #expect(error.description.isEmpty == false)
}

@Test func DescriptionPrefersLibshoutMessage() async throws {
    let error = ShoutError(code: .noConnect, message: "Couldn't connect to server")
    #expect(error.description == "Couldn't connect to server")
}

@Test func ThrownErrorCapturesLibshoutMessageEagerly() async throws {
    shout_init()
    let connection = try #require(ShoutConnection())
    connection.setHost("127.0.0.1")
    connection.setPort(1)
    connection.setUser("source")
    connection.setPassword("hackme")
    connection.setMount("/test")
    connection.setContentFormat(format: .mp3, usage: .audio)

    let error = try #require(throws: ShoutError.self) { try connection.open() }
    // libshout's shout_get_error() string is only valid until the next call
    // on the handle; ShoutError copies it eagerly, so it stays readable even
    // after further libshout calls have overwritten the C-side buffer.
    _ = connection.isConnected
    #expect(error.message.isEmpty == false)
    #expect(error.description == error.message)
}

@Test func UnknownCodeIsRepresentable() async throws {
    let code = ShoutError.Code(rawValue: -999)
    #expect(code != .insane)
    #expect(code.description.contains("-999"))
}
