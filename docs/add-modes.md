# Add modes - what are they?
The mod manager currently supports a number of different modes while managing mods. Which one a mod ends up as is determined by the `Add mode` dropdown, next to the `Add mods` button:

![The 'Add mode' dropdown](/docs/res/add-mode-dropdown.png)

The mods added will follow the mode that's selected while they're being added. You can hover over either option for a quick description, and we'll go through them more thorougly below.

We'll start with the default one:

## Move on add
As the name might suggest, this will move any mod files as soon as they're added into the editor. What exactly this means depends on the type of mod you're adding.

For example, an `ESP/ESM` mod will be moved to Oblivion's `Data` directory, where they lie when installed. The mod will however not be added to the `Plugins.txt` file, activating it.  
Similarly, `UE4SS` mods will be moved to the `UE4SS` `Mods` folder. `OBSE` and `Pak` mods will be moved to a temporary "available mods" directory.

Once the mod is moved into the `Active` list, it will then be activated (`ESP/ESM` mods will be added to `Plugins.txt`, etc.).

Once a mod is then deactivated and subsequently removed (via the `Remove mods` button), it will simply be put in the trash can.

## Copy on activation
As opposed to the `Move on add` option above, this mode won't touch the files until they're activated. This means that it will cache the path to the mod files, and use said path to copy the files over once they're activated.  
This is so you can keep a safe copy of your mod files somewhere else, without running into the risk of them being overwritten, etc.

Once a `Copy on activation` mod is deactivated, the files associated with it will be removed immediately. The remembered path cache will be removed on mod removal (via the `Remove mods` button).

The big difference between this and `Move on add` is that you get to keep the files where they were, and only have copies of them be installed while active. That, and `Copy on activation` mods are written out with cyan names.
