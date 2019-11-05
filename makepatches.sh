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
# if [ -n "$string" ] returns true, if the string is not empty, meaning in this case, that there are changes
# in the working directory.
if [ -n "`git status --porcelain --ignore-submodules=dirty`" ];then
  patchpath="${patchdir}/root.patch";
  # Writing the diff for unstaged and staged changes to $patchpath.
  git diff --ignore-submodules=dirty > "$patchpath"
  git diff --ignore-submodules=dirty --staged >> "$patchpath"
  echo "Created patch for project root"
fi

# Similar to the code above, but additionally:
# \$(realpath --relative-to=\"$projectroot\" \"\$PWD\") returns the path of the submodule relative to the root.
# \${relpath//\\//.} returns relpath, but replaced every '/' with '.'
submodulecode=":
if [ -n \"\`git status --porcelain --ignore-submodules=dirty\`\" ];then
  relpath=\`realpath --relative-to=\"$projectroot\" \"\$PWD\"\`;
  patchpath=\"\${relpath//\\//.}\";
  patchpath=\"${patchdir}/submodule-\${patchpath}.patch\";
  git diff --ignore-submodules=dirty > \"\$patchpath\";
  echo \"Created patch for \${relpath}\";
fi"

git submodule foreach --recursive -q bash -c "$submodulecode"
