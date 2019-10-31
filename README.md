# automated-moodle-patching

Scripts for automatically making patches for and applying patches to repositories and (recursive) submodules.

### makepatches.sh
usage: `makepatches.sh PATCH_DIR`

`PATCH_DIR` The folder the patches should be saved to 


Has to be executed from the root of a git repository.

Saves a patch containing all uncommited changes of the repository to `PATCH_DIR/root.patch` 
and a patch for each submodule in `PATCH_DIR/submodule-path.to.submodule.patch`, where `path/to/submodule` is the relative
path from the repository root to the submodule.

The patch is created with the `--ignore-submodule=dirty` option, so that changes to the HEAD of the submodule are saved.

### applypatches.sh
usage: `applypatches.sh PATCH_DIR`

`PATCH_DIR` The folder containing the patches


Has to be executed from the root of a git repository.

Applies the patches in `PATCH_DIR` to their respective repository / submodules.