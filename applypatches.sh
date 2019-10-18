#!/bin/bash
patchdir=$1
projectroot=$PWD

if [ ! -d ".git" ]; then
  echo "This script needs to be called from a git root dir."
  exit
fi

if [ ! -d "$patchdir" ]; then
  echo "The patch folder does not exist."
fi

# Make patchdir an absolute path
patchdir="$(realpath "$patchdir")"

patchpath="${patchdir}/root.patch";
# If the patch-file does exist:
if [ -a "$patchpath" ]; then
  # Apply the patch. --index seems to be needed in order to apply submodule updates.
  git apply --index "$patchpath"
  git submodule update --init
fi

submodulecode="
relpath=\$(realpath --relative-to=\"$projectroot\" \"\$PWD\");
patchpath=\"\${relpath//\\//\\.}\";
patchpath=\"${patchdir}/submodule-\${patchpath}.patch\";
if [ -a \"\$patchpath\" ]; then
  git apply --index \"\$patchpath\"
  git submodule update --init
fi"

git submodule foreach --recursive -q bash -c "$submodulecode"
