/// Streams `[UInt8]` frames to an Icecast server without blocking the calling
/// task.
///
/// libshout's usual pacing call, `shout_sync()`, puts the calling thread to
/// sleep -- fine for a dedicated thread, wrong for Swift's cooperative
/// executors. `ShoutStreamer` instead runs the connection in nonblocking mode
/// and paces sends with `shout_delay()` + `Task.sleep`, so the task suspends
/// rather than the thread.
///
/// It is an `actor`: it owns a non-`Sendable` ``ShoutConnection`` and funnels
/// every libshout call through its executor, so one streamer can be shared
/// across tasks.
public actor ShoutStreamer {
    private let connection: ShoutConnection
    private var isOpen = false
    private var isStreaming = false

    /// Builds a streamer around a fresh connection.
    ///
    /// `configuration`'s `nonblocking` is forced to `.none`
    /// (`SHOUT_BLOCKING_NONE`); the async pacing depends on it.
    public init(configuration: ShoutConfiguration) throws(ShoutError) {
        var configuration = configuration
        configuration.nonblocking = BlockingMode.none
        self.connection = try ShoutConnection(configuration: configuration)
    }

    // No deinit: stream(_:) closes the connection on every exit path, and it
    // retains the actor for as long as it runs (even while suspended), so the
    // connection is never still open when the streamer is deallocated.
    // ShoutConnection's own deinit then frees the handle.

    /// Consumes `frames` and sends each to the server.
    ///
    /// The connection is opened when streaming starts and closed when `frames`
    /// ends, throws, or the task is cancelled. Sends are paced to real time
    /// with `shout_delay()`, so a faster-than-realtime sequence is throttled
    /// and a slower one streams as it arrives.
    ///
    /// - Throws: ``ShoutStreamerError/alreadyStreaming`` if a previous call is
    ///   still running; ``ShoutError`` if libshout rejects the connection or a
    ///   send; `CancellationError` if the task is cancelled; or whatever
    ///   `frames` itself throws.
    public func stream<Frames: AsyncSequence & Sendable>(
        _ frames: Frames
    ) async throws where Frames.Element == [UInt8] {
        guard !isStreaming else { throw ShoutStreamerError.alreadyStreaming }
        isStreaming = true
        defer { isStreaming = false }

        do {
            try await openIfNeeded()
            for try await frame in frames {
                try Task.checkCancellation()
                try await send(frame)
                try await pace()
            }
            try await drain()
        } catch {
            close()
            throw error
        }
        close()
    }

    /// Replaces the in-stream MP3/AAC metadata, e.g.
    /// `["song": "Artist - Track"]`.
    ///
    /// Safe to call while `stream(_:)` is running -- the actor runs it between
    /// sends. Throws ``ShoutStreamerError/notStreaming`` if the connection
    /// isn't open yet, since `shout_set_metadata_utf8()` crashes on a
    /// never-opened handle. Takes a plain dictionary (not a ``ShoutMetadata``)
    /// so nothing non-`Sendable` has to cross into the actor.
    public func updateMetadata(_ entries: [String: String]) throws {
        guard isOpen else { throw ShoutStreamerError.notStreaming }
        guard let metadata = ShoutMetadata() else {
            throw ShoutError(code: .malloc, message: "shout_metadata_new() failed")
        }
        for (name, value) in entries {
            try metadata.add(name: name, value: value)
        }
        try connection.setMetadataUTF8(metadata)
    }

    // MARK: - Internals

    private func openIfNeeded() async throws {
        guard !isOpen else { return }
        do {
            try connection.open()
        } catch {
            // `error` is a ShoutError (open() has typed throws). In nonblocking
            // mode open() returns .busy to mean "TCP connected, still
            // handshaking" -- from there you poll shout_get_connected() rather
            // than call open() again. Anything else is a real failure.
            guard error.code == .busy || error.code == .retry else { throw error }
            try await waitForConnection()
        }
        isOpen = true
    }

    // Polls shout_get_connected() until the nonblocking connect finishes.
    // Unbounded on purpose: cancel the task to abandon a connect that never
    // completes (Task.sleep throws CancellationError, which propagates out).
    private func waitForConnection() async throws {
        while true {
            try await Task.sleep(for: .milliseconds(20))
            let status = connection.connectionStatus
            if status == .connected { return }
            guard status == .busy else {
                throw ShoutError(code: status, message: connection.errorDescription)
            }
        }
    }

    private func send(_ frame: [UInt8]) async throws {
        while true {
            do {
                try connection.send(frame)
                return
            } catch {
                // ShoutError; .busy / .retry means the write queue is full.
                guard error.code == .busy || error.code == .retry else { throw error }
                try await Task.sleep(for: .milliseconds(10))
            }
        }
    }

    private func pace() async throws {
        let delay = connection.delay
        guard delay > 0 else { return }
        try await Task.sleep(for: .milliseconds(delay))
    }

    // Best effort: service libshout's nonblocking write queue so the tail of
    // the stream reaches the server before close(). Bounded so a wedged socket
    // can't hang the caller, and tolerant of send errors -- a failed flush
    // just means an early close, same as no drain at all.
    private func drain() async throws {
        var attempts = 0
        while connection.queueLength > 0, attempts < 250 {
            attempts += 1
            do {
                try connection.send([])
            } catch {
                guard error.code == .busy || error.code == .retry else { return }
            }
            if connection.queueLength > 0 {
                try await Task.sleep(for: .milliseconds(20))
            }
        }
    }

    private func close() {
        connection.close()
        isOpen = false
    }
}

/// Errors specific to ``ShoutStreamer`` (libshout's own failures arrive as
/// ``ShoutError``).
public enum ShoutStreamerError: Error, Sendable, Equatable {
    /// `stream(_:)` was called while a previous call was still running.
    case alreadyStreaming
    /// An operation that needs an open connection ran before `stream(_:)`
    /// opened one.
    case notStreaming
}
