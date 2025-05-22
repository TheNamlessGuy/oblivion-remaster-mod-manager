# Changelog

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
