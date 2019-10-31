#!/bin/bash
patchdir=$1
projectroot=$PWD

if [ $# != 1 ]; then
  echo "usage: ./applypatches.sh PATCH_DIR"
  exit
fi

if [ ! -d ".git" ]; then
  echo "This script needs to be called from a git root dir."
  exit
fi

# If $patchdir does not exist, create $patchdir and parent folders.
if [ ! -d "$patchdir" ]; then
  mkdir -p "$patchdir"
fi

# Make patchdir an absolute path
patchdir="$(realpath "$patchdir")"

# Check whether there are changes in this repository.
# dirty submodules are ignored, because otherwise, the patch would contain a note,
# that the submdule is on commit 123abc-dirty, and the git apply would not work.
git diff --quiet --exit-code --ignore-submodules=dirty
# If last return code is 1 (= git diff detected changes
if [ "$?" -eq "1" ];then
  patchpath="${patchdir}/root.patch";
  git diff --ignore-submodules=dirty > "$patchpath"
  echo "Created Patch for project root"
fi

# Similar to the code above, but additionally:
# \$(realpath --relative-to=\"$projectroot\" \"\$PWD\") returns the path of the submodule relative to the root.
# \${relpath//\\//\\.} returns relpath, but replaced every '/' with '.'
submodulecode="git diff --ignore-submodules=dirty --quiet --exit-code
if [ \"\$?\" -eq \"1\" ];then
  relpath=\$(realpath --relative-to=\"$projectroot\" \"\$PWD\");
  patchpath=\"\${relpath//\\//\\.}\";
  patchpath=\"${patchdir}/submodule-\${patchpath}.patch\";
  git diff --ignore-submodules=dirty > \"\$patchpath\"
  echo \"Created Patch for \${relpath}\"
fi"

git submodule foreach --recursive -q bash -c "$submodulecode"
