#!/bin/bash

if [ $# != 2 ]; then
  echo "This script should not be called directly."
  exit
fi

patchdir=$1
projectroot=$2

scriptpath="`realpath $0`"
scriptpath="`dirname $scriptpath`"
scriptpath="`realpath $scriptpath`"

relpath="`realpath --relative-to="$projectroot" "$PWD"`"
patchpath="${relpath//\//.}"
patchpath="${patchdir}/submodule-${patchpath}.patch"
if [ -a "$patchpath" ]; then
  if [ -n "`git apply --check "$patchpath" 2>&1`" ]; then
      echo "ERROR: Could not apply patch for ${relpath} and submodules:"
      git apply --check --reject "$patchpath" 2>&1
      echo -e "\nTry running"
      echo "    \"${scriptpath}/.applyrecursive.sh\" \"${patchdir}\" \"${projectroot}\""
      echo "in the `realpath $PWD` directory after resolving the conflicts."
      exit;
  fi
  git apply "$patchpath"
  echo "Applied patch for ${relpath}"
  git submodule update --init
fi

git submodule foreach -q bash -c ":;\"${scriptpath}/.applyrecursive.sh\" \"${patchdir}\" \"${projectroot}\""
