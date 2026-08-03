# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

SwiftShout is a Swift wrapper package around `libshout`, the C streaming
library used to source audio/video streams to an Icecast server. It is a
very early-stage package: the `SwiftShout` type currently just calls
`shout_init()` and prints the linked libshout version via
`shout_version()`.

## Prerequisites

Building requires the `libshout` C library and its pkg-config file to be
installed on the host, since `CShout` is a system library target that
resolves via `pkgConfig: "shout"`:

```bash
brew install libshout       # macOS
# or: apt install libshout-dev   # Linux
```

## Common commands

```bash
swift build      # build the library
swift test        # run the test suite (Swift Testing, not XCTest)
swift test --filter InitSwiftShout   # run a single test by name
```

There is no linter configured in this repo.

## Architecture

- `Sources/CShout/` — a `.systemLibrary` target that exposes the C
  `libshout` headers to Swift. `module.modulemap` maps `shout.h` (vendored
  from upstream libshout, unmodified) into the `CShout` module and links
  `libshout`. Package resolution of the library itself happens via
  pkg-config (see `Package.swift`), not via the vendored header.
- `Sources/SwiftShout/SwiftShout.swift` — the actual Swift wrapper target,
  depends on `CShout` and calls the C API directly (e.g.
  `shout_init()`, `shout_version()`). Interop with the C API leans on
  `UnsafeMutablePointer` for out-parameters, since libshout's C functions
  use pointer-based outputs (e.g. `shout_version(&major, &minor, &patch)`).
- `Tests/SwiftShoutTests/` — uses the Swift Testing framework (`import
  Testing`, `@Test` macro), not XCTest.
- `swiftLanguageModes: [.v6]` in `Package.swift` — this package targets
  Swift 6 language mode, so strict concurrency checking applies to any new
  code.

## Constraints
- Prefer using `Span` and `MutableSpan` over `UnsafePointer` and
  `UnsafeMutablePointer`.  Suggest refactoring to use `Span` when an
  `UnsafePointer` is being used in existing code.
- Use the tone and format of existing Git commit messages for any new commit
  messages.
