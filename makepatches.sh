#!/bin/bash
patchdir=$1
projectroot=$PWD

if [ ! -d ".git" ]; then
  echo "This script needs to be called from a git root dir."
  exit
fi

if [ ! -d "$patchdir" ]; then
  mkdir -p "$patchdir"
fi

patchdir="$(realpath "$patchdir")"

git diff --quiet --exit-code
if [ "$?" -eq "1" ];then
  patchpath="root";
  patchpath="${patchdir}/${patchpath}.patch";
  git diff --ignore-submodules=all > "$patchpath"
  echo "Created Patch for project root"
fi

submodulecode="git diff --quiet --exit-code
if [ \"\$?\" -eq \"1\" ];then
  relpath=\$(realpath --relative-to=\"$projectroot\" \"\$PWD\");
  patchpath=\"\${relpath//\\//\\~}\";
  patchpath=\"${patchdir}/\${patchpath}.patch\";
  git diff --ignore-submodules=all > \"\$patchpath\"
  echo \"Created Patch for \${relpath}\"
fi"

git submodule foreach --recursive -q bash -c "$submodulecode"
