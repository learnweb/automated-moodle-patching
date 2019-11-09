#!/bin/bash
patchdir=$1
projectroot=$PWD

if [ $# != 1 ]; then
  echo "usage: ./makepatches.sh PATCH_DIR"
  exit
fi

if [ ! -d ".git" ]; then
  echo "This script needs to be called from a git root directory."
  exit
fi

# If $patchdir does not exist, create $patchdir and parent folders.
if [ ! -d "$patchdir" ]; then
  mkdir -p "$patchdir"
fi

# Make patchdir an absolute path
patchdir="`realpath "$patchdir"`"

# Check whether there are changes in this repository.
# dirty submodules are ignored, because otherwise, the patch would contain a note,
# that the submdule is on commit 123abc-dirty, and the git apply would not work.
# The patch will be only created, if the output of `git diff --ignore-submodules=dirty` is not empty.
if [ -n "`git diff --ignore-submodules=dirty`" ];then
  patchpath="${patchdir}/root.patch";
  git diff --ignore-submodules=dirty > "$patchpath"
  echo "Created patch for project root"
fi

# Similar to the code above, but additionally:
# \$(realpath --relative-to=\"$projectroot\" \"\$PWD\") returns the path of the submodule relative to the root.
# \${relpath//\\//.} returns relpath, but replaced every '/' with '.'
submodulecode=":
git diff --quiet --exit-code
if [ -n \"\`git diff --ignore-submodules=dirty\`\" ];then
  relpath=\"\`realpath --relative-to=\"$projectroot\" \"\$PWD\"\`\"
  patchpath=\"\${relpath//\\//.}\"
  patchpath=\"${patchdir}/submodule-\${patchpath}.patch\"
  git diff --ignore-submodules=dirty > \"\$patchpath\"
  echo \"Created patch for \${relpath}\"
fi"

git submodule foreach --recursive -q bash -c "$submodulecode"
