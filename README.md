# SwiftShout

A Swift wrapper around [libshout](https://gitlab.xiph.org/xiph/icecast-libshout), the C streaming library used to "stream" audio/video data to an [Icecast](https://icecast.org) (preferred) or Shoutcast server.

## License

This project is licensed under the Apache v2 software license.

Please note that the upstream package, the [Icecast server](https://www.icecast.org/), is licensed under the GNU GPLv2.  Distributing both projects together would most likely cause this project to be re-licensed under the GNU GPLv2.  We are not lawyers, consult a lawyer if any of this concerns you at all.

## Prerequisites

- Swift 6.x toolchain.  This project has been tested with Swift 6.x on both macOS and Linux.
- [`libshout`](https://icecast.org/) and its `pkg-config` file

To install `libshout` on macOS:
```bash
brew install libshout
```

And for Debian/Ubuntu:
```bash
apt install libshout-dev
```

## Building and testing

```bash
swift build       # build the library
swift test         # run the test suite (Swift Testing, not XCTest)
swift test --filter InitSwiftShout   # run a single test by name
```

### The `-D_THREAD_SAFE` warning is expected

Both commands print this twice:

```
warning: prohibited flag(s): -D_THREAD_SAFE
```

It is harmless, and there is nothing to fix in this package. `libshout`
ships that flag in the `Cflags:` line of its own `shout.pc`, and SwiftPM
accepts only `-I`/`-L`/`-l` flags out of a `pkg-config` file -- it warns
about anything else and then drops it. The warning is emitted while
SwiftPM parses a file the `libshout` packager owns, which is upstream of
both `Package.swift` and `Sources/CShout/module.modulemap`, so nothing
here can suppress it. `libshout` does not need `-D_THREAD_SAFE` on a
current Darwin or glibc toolchain, so dropping it changes nothing.

## Usage

```swift
import SwiftShout

print("libshout \(SwiftShout.libshoutVersion)")

let configuration = ShoutConfiguration(
    host: "icecast.example.com",
    port: 8000,
    user: "source",
    password: "hackme",
    mount: "/stream",
    format: .mp3
)

do {
    let connection = try ShoutConnection(configuration: configuration)
    defer { connection.close() }

    try connection.open()

    // read in a chunk of data as 'mp3frame'
    let mp3Frame: [UInt8] = /* ... */ []
    // send it to the Icecast server...
    try connection.send(mp3Frame)

    // if the file has metadata (artist/track title), update it on the Icecast server
    if let metadata = ShoutMetadata() {
        try metadata.add(name: "song", value: "Artist - Track")
        try connection.setMetadataUTF8(metadata)
    }
} catch let error as ShoutError {
    fatalError("stream failed: \(error)")   // e.g. "Couldn't connect to server"
}
```

## Related Projects

* _SimpleShout_, the simplest example of streaming to a Shoutcast/Icecast server using this _SwiftShout_ framework.  Tested exclusively with Icecast only.  This example project should always stay in sync with the public interfaces of _SwiftShout_; in other words, it should always "just work (tm)".

## Development & Framework Internals

### Streaming without blocking

`ShoutStreamer` is an `actor` that drives a connection in nonblocking
mode and paces sends with `shout_delay()` + `Task.sleep` instead of the
thread-blocking `shout_sync()`. Hand it an `AsyncSequence` of `[UInt8]`
frames:

```swift
let streamer = try ShoutStreamer(configuration: configuration)

try await streamer.stream(mp3Frames)          // some AsyncSequence<[UInt8]>
// ...or, from another task while streaming:
try await streamer.updateMetadata(["song": "Artist - Track"])
```

`stream(_:)` opens the connection, sends each frame paced to real time,
and closes on completion, error, or task cancellation. It owns the
non-`Sendable` `ShoutConnection`, so the `actor` is what makes the whole
thing `Sendable`.

`ShoutConfiguration` is a `Sendable`, `Equatable` value holding every
pre-`open()` setting; `ShoutConnection(configuration:)` (or
`config.apply(to:)` on an existing connection) applies it in one step,
throwing `ShoutError` if libshout rejects any field. The individual
setters are still there -- each returns the underlying `SHOUTERR_*`
code from libshout and is `@discardableResult`, since libshout doesn't
mark the setters `warn_unused_result` and ignoring a stored-parameter
status is usually harmless. The actions it *does* mark
`warn_unused_result` --
`open()`, `send(_:)`, `sendRaw(_:)`, `setMetadataUTF8(_:)`, and
`ShoutMetadata.add(name:value:)` -- instead throw `ShoutError`
(a typed `throws(ShoutError)`), which pairs the `SHOUTERR_*` `Code`
with the description libshout produced for it. `sendRaw(_:)` still
returns the byte count it wrote. In nonblocking mode, a thrown
`ShoutError` whose `code` is `.busy` or `.retry` means "call again",
not a hard failure.

Settings that libshout expresses as raw integer or string constants
(`SHOUT_TLS_*`, `SHOUT_PROTOCOL_*`, `SHOUT_FORMAT_*`/`SHOUT_USAGE_*`,
`SHOUT_META_*`, `SHOUT_AI_*`) are wrapped as typed values --
`TLSMode`, `StreamProtocol`, `ContentFormat`, `ContentUsage`,
`BlockingMode`, `MetaKey`, `AudioInfoKey` -- so call sites use
`.disabled`, `.icy`, `.ogg`, `.name`, etc. instead of magic numbers.

### Framework Architecture

`ShoutConnection` wraps libshout'sconnection handle (`shout_t`) and covers essentially all of its non-deprecated API; `ShoutConfiguration` collects the pre-`open()` settings into one value; `ShoutStreamer` is an `actor` that streams an `AsyncSequence` of frames without blocking the calling task; and `ShoutMetadata` wraps in-stream metadata updates for MP3/AAC streams.  There is no support yet for the two advanced, TLS-peer-certificate-verification entry points (`shout_control`, `shout_set_callback`) -- libshout itself marks both "Advanced. Do not use."

- `Sources/CShout/` -- a `.systemLibrary` target that exposes the C
  `libshout` headers to Swift. `module.modulemap` maps `shout.h`
  (vendored from upstream libshout, unmodified) into the `CShout`
  module and links `libshout`. Package resolution of the library
  itself happens via pkg-config (see `Package.swift`), not via the
  vendored header.
- `Sources/SwiftShout/SwiftShout.swift` -- calls `shout_init()` on
  construction and `shout_shutdown()` via a static method; these are
  process-global, not tied to any one connection.
- `Sources/SwiftShout/ShoutConnection.swift` -- wraps a `shout_t`
  handle (`shout_new`/`shout_free`) and the bulk of libshout's
  per-connection API: host/port/credentials/mount, TLS and CA
  settings, content format/usage, protocol, audio info, in-stream
  meta, blocking mode, open/close, and send/send_raw.
- `Sources/SwiftShout/ShoutMetadata.swift` -- wraps a
  `shout_metadata_t` handle (`shout_metadata_new`/`_free`/`_add`) used
  with `ShoutConnection.setMetadataUTF8(_:)` for MP3/AAC in-stream
  metadata (song/title updates), distinct from the static per-mount
  meta (`SHOUT_META_*`) set on `ShoutConnection` itself.
- `Sources/SwiftShout/ShoutConfiguration.swift` -- `ShoutConfiguration`,
  a `Sendable`/`Equatable` value holding every pre-`open()` setting;
  `apply(to:)` drives the individual setters, and
  `ShoutConnection(configuration:)` builds a connection from one.
- `Sources/SwiftShout/ShoutStreamer.swift` -- `ShoutStreamer`, an
  `actor` that owns an opened connection and streams an
  `AsyncSequence` of frames to it, pacing with `shout_delay()` +
  `Task.sleep` (nonblocking mode) rather than blocking on
  `shout_sync()`. `ShoutStreamerError` covers its non-libshout
  failure cases.
- `Sources/SwiftShout/ShoutTypes.swift` -- typed wrappers around
  libshout's `SHOUT_*` constant groups.
- `Sources/SwiftShout/ShoutError.swift` -- `ShoutError`, the typed
  error thrown by the `warn_unused_result` actions; wraps a
  `SHOUTERR_*` `Code` and libshout's message string.
- `Tests/SwiftShoutTests/` -- uses the Swift Testing framework
  (`import Testing`, `@Test` macro), not XCTest. Tests that need a
  live connection point at an unreachable local port rather than a
  real Icecast server, to exercise the wrapper's plumbing without
  network dependencies.
- `swiftLanguageModes: [.v6]` in `Package.swift` -- this package
  targets Swift 6 language mode, so strict concurrency checking
  applies to any new code.

### Project Constraints

- Prefer `Span`/`MutableSpan` over `UnsafePointer`/`UnsafeMutablePointer`
  for new code.
