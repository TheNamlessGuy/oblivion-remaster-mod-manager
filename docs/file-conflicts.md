# File conflicts
Since this mod manager copies, moves, and puts files in the trashcan, there's a possibility that there might exist conflicts every once in a while. This should only really happen if you're managing mods yourself while simultaneously also managing mods using NORMM, so the vast majority of users shouldn't encounter these issues. But they still can happen, and NORMM takes that into account.

When a file conflict is encountered, NORMM will give you a prompt with your choices.

Let's go through each scenario, why it could happend, and what NORMM can do in those cases.

## Adding a new mod, but there's an existing mod with the same name
This is probably the most common scenario. You're adding the mod `MyCoolMod.esp`, but whoops, it's already installed! What should happen in this case?

### How it could happen
Simply by human error. Maybe you forgot you installed the mod already. Maybe you manually copied the file to the destination before adding it via NORMM.

### What NORMM can do
NORMM offers two resolutions to this issue:
* Skip  
    Simply don't add the mod.
* Replace
    Replace the existing mod with the new one.

## Activating a mod, but there are conflicting files already present in the active mod directory
This is mostly the case for [`Copy on activaton`](/docs/add-modes.md) mods, but there are some mod types that consider a mod active when it's simply existing in a folder. These types of mods will have to be moved on activation as well, meaning this scenario could happen to them.

### How it could happen
This should only happen if a user manually moves files around, then uses NORMM on top of those changes.

### What NORMM can do
NORMM offers two resolutions to this issue:
* Deactivate  
    Leave the mod as `Available`.
* Replace
    Replace the existing mod.

## Deactivating a mod, but there are conflicting files already present in the available mod directory
This is mostly the case for [`Copy on activaton`](/docs/add-modes.md) mods, but there are some mod types that consider a mod active when it's simply existing in a folder. These types of mods will have to be moved on deactivation as well, meaning this scenario could happen to them.

### How it could happen
This should only happen if a user manually moves files around, then uses NORMM on top of those changes.

### What NORMM can do
NORMM offers three resolutions to this issue:
* Leave  
    Leave the files where they are. Usually, this will mean that the mod won't get deactivated.
* Move back  
    Move the files back to the Available mod directory.
* Remove  
    Delete the files of the mod you're deactivating.

## Deactivating a `Copy on activation` mod, and the original file it was copied from is missing
When activating a `Copy on activation` mod, the mod files will be copied over to the active mod directory. Thanks to that, it deletes the mod files on deactivation. However, if the original files are gone as well, this would mean that you lost the mod files entirely!

You can read more about how `Copy on activation` mods work [here](/docs/add-modes.md).

### How it could happen
The user manually deletes the copied files between activation and deactivation.

### What NORMM can do
NORMM offers three resolutions to this issue:
* Leave  
    Leave the files where they are. This may sometimes mean that the mod won't get deactivated.
* Move back  
    Move the files back to where they were copied from.
* Remove  
    Delete the mod files.
