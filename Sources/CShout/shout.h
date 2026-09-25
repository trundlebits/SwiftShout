// Trampoline to the real libshout header. Resolved via the -I search path
// pkgConfig supplies (Package.swift), not vendored here, so this stays in
// sync with whatever libshout is installed and avoids committing
// libshout's own LGPL-licensed source into this repo.
#include <shout/shout.h>
