# Changelog

## Version 0.5.0
Features:
* Show a list of mod files related to the mod on hover

Fixes:
* Remove dwmapi.dll requirement for UE4SS to register as installed
* Ignore MagicLoader 2.0 folders instead of the 1.0 folder
* Allow for UnrealPak mods that end with '_p', and not '_P' (even though the documentation says only '_P' is allowed, but since it allows it I guess they like lying)
* UnrealPak mods should now uninstall properly (left an empty folder previously)

Internal improvements:
* Separate FileSystem::_DISABLE_ACTIONS into _DISABLE_ACTIONS and _LOG_ACTIONS

## Version 0.4.2
Fixes:
* Mod type selected per mod selector didn't propagate well during tab move

## Version 0.4.1
Fixes:
* Manager folder should no longer be accesssed with the name '.d'

## Version 0.4.0
Features:
* Backing up ESP/ESM mods
* Added '--manager-folder' command line option
* NPC Appearance Manager support

Fixes:
* Loosened up UE4SS mod dir restrictions
* The binary and the manager folder should never end up with the same name anymore, which would cause instant crashes previously
* Sorted mod types (tabs and in the settings page) alphabetically

Internal improvements:
* Added notifications

## Version 0.3.0
Features:
* Linux support (cannot run MagicLoader automatically yet!)
* TesSyncMapLoader support

Internal improvements:
* Restructured a lot. DRY and for ease of adding new mod types in the future

## Version 0.2.0
Features:
* MagicLoader support
* Rudimentary "Guess installation path" feature
* Made things more GamePass friendly (should now work?)

Fixes:
* Moved "Reload" button down next to "Save" button
* Added version number display in the bottom left

Internal improvements:
* Added custom dialog system for more flexibility
* Added support for custom buttons in ModSelector

## Version 0.1.0
Features:
* Removed "choice" settings, added prompting system on file conflict
* Added [custom theme support](/docs/custom-theme.md)

Fixes:
* Allow for GamePass users to select their `.exe`, which is named differently for whatever reason

Internal improvements:
* Improved typing - added a lot, and swapped to walrus assignment where applicable

## Version 0.0.1
Features:
* `.esp` and `.esm` mod support
* Unreal `.pak` mod support
* `OBSE` mod support
* `UE4SS` mod support
