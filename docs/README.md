# The NORMM user guide section
Hello! We have some fine user guides available for you. If you're new here, we'd recommend going from top to bottom in the following list:

* [Getting Started](/docs/getting-started.md)
* [Add modes - what are they?](/docs/add-modes.md)
* [Settings - what do they mean?](/docs/settings.md)
* [File conflicts](/docs/file-conflicts.md)

You'll find a full list of user guides at the bottom of the page.  
We also have a FAQ section below.

## Frequently Asked Questions
### Does using NORMM lock me into using it for my mod management?
No! NORMM is specifically designed to be used as much or as little as you want. You can use it to install one mod, delete it, and you won't even know it was there.

### When I ran NORMM, Windows Smart Defender said it "protected my PC". What gives?
You can read more about this issue [here](/docs/getting-started.md#windows-defender-smartscreen-popup).

### Why is the name of one of my mods a different color?
NORMM uses a few colors for mod names to give you more information about them. Generally, you can hover over them to get a description of why it's a different color, but here's an overlook:
* Cyan/Blue  
    The mod was added using the add mode `Copy on activation`. You can read more about this [here](/docs/add-modes.md).
* Red  
    The mod manager can see that there was a mod here once, but it's no longer present. Usually, this is because of users manually managing mods.
* Yellow  
    The mod has been manually installed in a way that the mod manager can't (currently) handle. For example, NORMM does not support enabling `UE4SS` mods using the `enabled.txt` option, nor `.pak` mods that aren't located in a folder with the name of the mod.

### Since this moves files around, what happens if there's a file with the same name already present?
You can read more about file conflicts and how they're handled [here](/docs/file-conflicts.md).

### Moving files around sounds scary! Does NORMM ever permanently delete things?
NORMM tries its best to never permanently remove data for you. Therefore, it moves things to the trash can instead of permanently deleting files as often as possible.

Note that files _will_ be permanently deleted if you've disabled trash can functionality in your operating system. If you don't understand what that means it won't affect you, so don't worry!

## Full guide list
* [Getting Started](/docs/getting-started.md)
* [Add modes - what are they?](/docs/add-modes.md)
* [Settings - what do they mean?](/docs/settings.md)
* [File conflicts](/docs/file-conflicts.md)
* [Custom themes](/docs/custom-theme.md)
