import Testing
import CShout
@testable import SwiftShout

#if canImport(Darwin)
import Darwin

/// A throwaway TCP listener that accepts the connection at the kernel level but
/// never speaks HTTP back, so libshout's nonblocking `shout_open()` returns
/// `.busy` and stays there -- enough to park `ShoutStreamer` in its connect
/// wait without needing a real Icecast server.
private func makeSilentListener() -> (descriptor: Int32, port: UInt16)? {
    let descriptor = socket(AF_INET, SOCK_STREAM, 0)
    guard descriptor >= 0 else { return nil }

    var address = sockaddr_in()
    address.sin_family = sa_family_t(AF_INET)
    address.sin_addr.s_addr = inet_addr("127.0.0.1")
    address.sin_port = 0   // ephemeral

    let bound = withUnsafePointer(to: &address) { pointer in
        pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            bind(descriptor, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
        }
    }
    guard bound == 0, listen(descriptor, 8) == 0 else {
        close(descriptor)
        return nil
    }

    var assigned = sockaddr_in()
    var length = socklen_t(MemoryLayout<sockaddr_in>.size)
    _ = withUnsafeMutablePointer(to: &assigned) { pointer in
        pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            getsockname(descriptor, $0, &length)
        }
    }
    return (descriptor, UInt16(bigEndian: assigned.sin_port))
}

private func streamerConfig(port: UInt16) -> ShoutConfiguration {
    ShoutConfiguration(
        host: "127.0.0.1",
        port: port,
        user: "source",
        password: "hackme",
        mount: "/test",
        format: .mp3
    )
}

/// A frame sequence that never yields and never finishes, so `stream(_:)`
/// stays parked after opening.
private func neverEndingFrames() -> AsyncStream<[UInt8]> {
    AsyncStream { _ in }
}

@Test func AlreadyStreamingIsThrownForOverlappingCalls() async throws {
    shout_init()
    let listener = try #require(makeSilentListener())
    defer { close(listener.descriptor) }

    let streamer = try ShoutStreamer(configuration: streamerConfig(port: listener.port))
    let first = Task { try await streamer.stream(neverEndingFrames()) }
    defer { first.cancel() }

    // Let the first call reach its connect wait and suspend the actor.
    try await Task.sleep(for: .milliseconds(300))

    await #expect(throws: ShoutStreamerError.alreadyStreaming) {
        try await streamer.stream(neverEndingFrames())
    }
}

@Test func CancellingStreamAbortsAConnectInProgress() async throws {
    shout_init()
    let listener = try #require(makeSilentListener())
    defer { close(listener.descriptor) }

    let streamer = try ShoutStreamer(configuration: streamerConfig(port: listener.port))
    let streaming = Task { try await streamer.stream(neverEndingFrames()) }

    try await Task.sleep(for: .milliseconds(300))
    streaming.cancel()

    await #expect(throws: CancellationError.self) {
        try await streaming.value
    }
}

@Test func StreamAgainstUnreachableServerThrowsShoutError() async throws {
    shout_init()
    // Port 1 on loopback: connection refused, so the nonblocking open fails
    // immediately rather than parking in `.busy`.
    let streamer = try ShoutStreamer(configuration: streamerConfig(port: 1))
    let frames = AsyncStream<[UInt8]> { continuation in
        continuation.yield([0, 1, 2, 3])
        continuation.finish()
    }

    await #expect(throws: ShoutError.self) {
        try await streamer.stream(frames)
    }
}

@Test func UpdateMetadataBeforeStreamingThrowsNotStreaming() async throws {
    shout_init()
    let streamer = try ShoutStreamer(configuration: streamerConfig(port: 1))

    await #expect(throws: ShoutStreamerError.notStreaming) {
        try await streamer.updateMetadata(["song": "Artist - Track"])
    }
}

#endif
