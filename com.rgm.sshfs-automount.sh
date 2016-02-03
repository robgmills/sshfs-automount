#!/bin/sh
/Library/Filesystems/osxfusefs.fs/Support/load_osxfusefs
sysctl -w osxfuse.tunables.allow_other=1
