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
import CShout      // for SHOUTERR_* return codes
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

guard connection.open() == SHOUTERR_SUCCESS else {
    fatalError(connection.errorDescription)
}

let mp3Frame: [UInt8] = /* ... */ []
_ = connection.send(mp3Frame)

if let metadata = ShoutMetadata() {
    _ = metadata.add(name: "song", value: "Artist - Track")
    _ = connection.setMetadataUTF8(metadata)
}

connection.close()
```

Every setter returns the underlying `SHOUTERR_*` code from libshout
(most are `@discardableResult`); `open()`, `send(_:)`, and
`sendRaw(_:)` are not, since ignoring their failures is the kind of
bug libshout's own `warn_unused_result` attribute exists to catch.

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
