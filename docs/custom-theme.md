# Custom themes
NORMM has support for custom themes. They use Godots built-in [themes](https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_theme_editor.html). Saving such a theme as `theme.tres` and storing it in the NORMM folder (same place as it saves settings and such), it will be loaded on startup.

## Creating your own theme
1) Download [Godot](https://godotengine.org/)
2) Either download the NORMM repository, or create an empty project.  
    If you create an empty one, none of your choices matter, since you'll be fine to delete said project once the theme is finished.
3) In the bottom left box (titled `FileSystem`), right click and select `New resource`:  
    ![Creating new Godot resource](/docs/res/godot-new-resource.png)
4) In the new window, search for `theme`, and double click on the matching item in the tree  
    ![Creating a Godot theme](/docs/res/godot-create-theme.png)
5) Name it `theme.tres` and save it in the default selected folder
6) The theme should now show up in your `FileSystem` section from earlier  
    ![Theme file in the Godot FileSystem](/docs/res/godot-theme-in-filesystem.png)
7) Double click on it to open the theme editor

From here on out, I recommend following the [official documentation](https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_theme_editor.html).

## NORMM-specific theming
In addition to the base Godot theming, NORMM also supports a few specific custom themes. How to handle these can be learned through the [`Manage and import items`](https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_theme_editor.html#manage-and-import-items) section of the Godot theme documentation.  
Adding a new custom type named like the `Type` field below, then adding an item of `item type` with the name `item name` allows you to control that particular custom element.

| What?                                       | Type                                                                                                           | Item type | Item name                      |
|---------------------------------------------|----------------------------------------------------------------------------------------------------------------|-----------|--------------------------------|
| The background color of the window          | `MainWindow`                                                                                                   | Color     | `background_color`             |
| The text color of errors                    | `ErrorLabel`                                                                                                   | Color     | `foreground_color`             |
| The text color of warnings                  | `WarningLabel`                                                                                                 | Color     | `foreground_color`             |
| The text color of info alerts               | `InfoLabel`                                                                                                    | Color     | `foreground_color`             |
| The text color of regular mods              | `BaseModSelector`, or the name of one of the [subclasses](/project/src/helper_scripts/components/mod_selector) | Color     | `mod_type__regular`            |
| The text color of "Copy on activation" mods | `BaseModSelector`, or the name of one of the [subclasses](/project/src/helper_scripts/components/mod_selector) | Color     | `mod_type__copy_on_activation` |
| The text color of "Not found" mods          | `BaseModSelector`, or the name of one of the [subclasses](/project/src/helper_scripts/components/mod_selector) | Color     | `mod_type__not_found`          |
| The text color of unmanageable mods         | `BaseModSelector`, or the name of one of the [subclasses](/project/src/helper_scripts/components/mod_selector) | Color     | `mod_type__unmanageable`       |
