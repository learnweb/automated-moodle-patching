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

git diff --quiet --exit-code --ignore-submodules=dirty
if [ "$?" -eq "1" ];then
  patchpath="${patchdir}/root.patch";
  git diff --ignore-submodules=dirty > "$patchpath"
  echo "Created Patch for project root"
fi

submodulecode="git diff --ignore-submodules=dirty --quiet --exit-code
if [ \"\$?\" -eq \"1\" ];then
  relpath=\$(realpath --relative-to=\"$projectroot\" \"\$PWD\");
  patchpath=\"\${relpath//\\//\\.}\";
  patchpath=\"${patchdir}/submodule-\${patchpath}.patch\";
  git diff --ignore-submodules=dirty > \"\$patchpath\"
  echo \"Created Patch for \${relpath}\"
fi"

git submodule foreach --recursive -q bash -c "$submodulecode"
