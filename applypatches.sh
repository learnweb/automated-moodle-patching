#!/bin/bash

if [ $# != 1 ]; then
  echo "usage: ./applypatches.sh PATCH_DIR"
  exit
fi

if [ ! -d ".git" ]; then
  echo "This script needs to be called from a git root dir."
  exit
fi

patchdir=$1
projectroot=$PWD

if [ ! -d "$patchdir" ]; then
  echo "usage: ./applypatches.sh PATCH_DIR"
  echo "The patch folder does not exist."
  exit
fi

# Make patchdir an absolute path
patchdir="`realpath "$patchdir"`"

patchpath="${patchdir}/root.patch";
# If the patch-file does exist:
if [ -a "$patchpath" ]; then
  # Apply the patch. --index seems to be needed in order to apply submodule updates.
  echo "Applying patch for project root";
  git apply "$patchpath"
  git submodule update --init
fi

submodulecode=":
relpath=\`realpath --relative-to=\"$projectroot\" \"\$PWD\"\`;
patchpath=\"\${relpath//\\//.}\";
patchpath=\"${patchdir}/submodule-\${patchpath}.patch\";
if [ -a \"\$patchpath\" ]; then
  echo \"Applying patch for \${relpath}\"
  git apply \"\$patchpath\";
  git submodule update --init
fi"

git submodule foreach --recursive -q bash -c "$submodulecode"
