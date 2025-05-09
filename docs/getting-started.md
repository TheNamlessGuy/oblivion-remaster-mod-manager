# Getting started
This guide will go through the basics of using the mod manager.

## Installation
Simply download the latest `.exe` from [nexusmods](https://www.nexusmods.com/oblivionremastered/mods/2737) or from [GitHub](https://github.com/TheNamlessGuy/oblivion-remaster-mod-manager/releases). Place the manager in whatever folder you want it to be in. I would recommend _not_ putting it in the Oblivion Remastered installation directory.

**Note**: Depending on what you do with it, the mod manager may spawn a folder with the same name as the executable next to it. This is where it stores settings and such.

After having placed the `.exe` somewhere, just double click on it to get started.

## Setup
The first thing you'll see on startup is the settings screen:

![The default settings screen](/docs/res/default-settings-screen.png)

Per default, the mod manager assumes you have a standard Steam Oblivion Remastered installation. If this isn't the case, you'll have to point it to where the game is installed.

For a standard Steam install, this should be something like:
```
C:\Program Files (x86)\Steam\steamapps\common\Oblivion Remastered
```
For GamePass, it should be:
```
C:\XboxGames\The Elder Scrolls IV- Oblivion Remastered
```

After that's set up, you can get started!

## Installing mods
We'll go through installing an `.esp` type mod first. The procedure for other mod types is very similar, so we'll only go over what differs briefly after this.

To start us off, head on over to the `ESP/ESM` tab:

![The 'ESP/ESM' tab](/docs/res/esp-esm-marked.png)

Assuming you haven't installed any mods previously, this is what the screen will look like. If you _have_ installed mods prior, don't worry! The mod manager can handle it.

Now, the first thing you have to do to start installing some mods is pointing out the mods to the mod manager. This is done by pressing the "Add mod" button:

![The 'Add mod' button](/docs/res/esp-esm-add-mod-button.png)

This will open up a popup letting you navigate to your file. You can select one, or multiple at once (as long as they're located in the same directory).

Once you've selected your mod, it should show up in the `Available mods` list:

![A mod is available!](/docs/res/esp-esm-available-mod.png)

In order to make the mod active within the game, select the mod by clicking on it, then pressing the ´Activate` button:

![Activating a mod](/docs/res/activating-esp-esm-mod.png)

It should now appear in the `Active mods` list. You'll notice that the tab title changed from `ESP/ESM` to `ESP/ESM (*)`. This means that you have unsaved changes. Quick, press the `Save` button to make sure your mod gets activated!

![Saving the changes](/docs/res/saving-esp-esm-changes.png)

Once the save button is pressed, the `(*)` should disappear from the tab title, and you're good to launch the game (now with mods)!

### Other mod types and their differences
The different mod types mainly differ in two ways:
* What files you're allowed to select - Don't worry, the mod manager will tell you what types it expects.  
    You may have noticed that you could only select `.esp` and `.esm` files if you followed the guide above. The other mod types will do the same.
* Whether or not you can control the order of them - The up/down arrows by the `Active mods` list will disappear when they're irrelevant.

Other than that, the procedure is the same.

## Other things to note
* As a general rule, if you're not sure what something means, try hovering your mouse cursor over it. You should get a little tooltip describing what the thing means.
* You can sort the order of your mods by clicking to select some, and then using the arrow buttons by the `Active mods` list.
* You can select multiple mods at once by either holding shift (will mark all mods between the currently marked and the one clicked), or by holding control (will mark the mods clicked on only)

### Further reading
That's the basic use-case! For some more advanced reading, follow the recommended list back in the [user guide hub](/docs/README.md).
