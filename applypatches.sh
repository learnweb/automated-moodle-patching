#!/bin/bash

if [ $# != 1 ]; then
  echo "usage: ./applypatches.sh PATCH_DIR"
  exit
fi

if [ ! -d ".git" ]; then
  echo "This script needs to be called from a git root directory."
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

scriptpath="`realpath $0`"
scriptpath="`dirname $scriptpath`"
scriptpath="`realpath $scriptpath`"

patchpath="${patchdir}/root.patch"
# If the patch-file does exist:
if [ -a "$patchpath" ]; then
  if [ -n "`git apply --check "$patchpath" 2>&1`" ]; then
    echo "ERROR: Could not apply patch for root and submodules:"
    git apply --check --reject "$patchpath" 2>&1
    echo -e "\nTry again after resolving the conflicts."
    exit;
  fi
  # Apply the patch.
  git apply "$patchpath"
  echo "Applied patch for project root"
  git submodule update --init
fi

git submodule foreach -q bash -c ":;\"${scriptpath}/.applyrecursive.sh\" \"${patchdir}\" \"${projectroot}\""
