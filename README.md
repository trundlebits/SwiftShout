# SwiftShout

A Swift wrapper around [libshout](https://gitlab.xiph.org/xiph/icecast-libshout),
the C streaming library used to source audio/video streams to an
[Icecast](https://icecast.org) server.

This is a very early-stage package. `ShoutConnection` wraps
libshout's connection handle (`shout_t`) and covers essentially all of
its non-deprecated API; `ShoutMetadata` wraps in-stream metadata
updates for MP3/AAC streams. There is no support yet for the two
advanced, TLS-peer-certificate-verification entry points
(`shout_control`, `shout_set_callback`) -- libshout itself marks both
"Advanced. Do not use."

## Prerequisites

Building requires the `libshout` C library and its pkg-config file to
be installed on the host, since `CShout` is a system library target
that resolves via `pkgConfig: "shout"`:

```bash
brew install libshout       # macOS
# or: apt install libshout-dev   # Linux
```

## Building and testing

```bash
swift build       # build the library
swift test         # run the test suite (Swift Testing, not XCTest)
swift test --filter InitSwiftShout   # run a single test by name
```

## Usage

```swift
import SwiftShout

print("libshout \(SwiftShout.libshoutVersion)")

guard let connection = ShoutConnection() else {
    fatalError("shout_new() failed")
}

connection.setHost("icecast.example.com")
connection.setPort(8000)
connection.setUser("source")
connection.setPassword("hackme")
connection.setMount("/stream")
connection.setContentFormat(format: .mp3, usage: .audio)

do {
    try connection.open()

    let mp3Frame: [UInt8] = /* ... */ []
    try connection.send(mp3Frame)

    if let metadata = ShoutMetadata() {
        try metadata.add(name: "song", value: "Artist - Track")
        try connection.setMetadataUTF8(metadata)
    }
} catch let error as ShoutError {
    fatalError("stream failed: \(error)")   // e.g. "Couldn't connect to server"
}

connection.close()
```

Every setter returns the underlying `SHOUTERR_*` code from libshout
and is `@discardableResult` -- libshout doesn't mark the setters
`warn_unused_result`, and ignoring a stored-parameter status is
usually harmless. The actions it *does* mark `warn_unused_result` --
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

## Architecture

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

## Constraints

- Prefer `Span`/`MutableSpan` over `UnsafePointer`/`UnsafeMutablePointer`
  for new code.
