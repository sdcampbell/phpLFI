# Package

version       = "0.1.0"
author        = "Steve Campbell"
description   = "Tests for LFI in PHP apps and automates the process of leveraging LFI's to recursively download source code and discover new files via includes to download additional source code files."
license       = "MIT"
srcDir        = "src"
bin           = @["phpLFI"]


# Dependencies

requires "nim >= 1.6.4"
