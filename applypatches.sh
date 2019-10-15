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

patchdir="$(realpath "$patchdir")"

patchpath="${patchdir}/root.patch";
if [ -a "$patchpath" ]; then
  git apply "$patchpath"
  git submodule update --init
fi

submodulecode="
relpath=\$(realpath --relative-to=\"$projectroot\" \"\$PWD\");
patchpath=\"\${relpath//\\//\\~}\";
patchpath=\"${patchdir}/\${patchpath}.patch\";
if [ -a \"\$patchpath\" ]; then
  git apply \"\$patchpath\"
  git submodule update --init
fi"

git submodule foreach --recursive -q bash -c "$submodulecode"
