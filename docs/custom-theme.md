# Custom themes
NORMM has support for custom themes. They use Godots built-in [themes](https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_theme_editor.html). Saving such a theme as `theme.tres` and storing it in the NORMM folder (same place as it saves settings and such), it will be loaded on startup.

## NORMM-specific theming
In addition to the base Godot theming, NORMM also supports a few specific custom themes. These are handled by the [`Manage and import items`](https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_theme_editor.html#manage-and-import-items) section of the Godot theme documentation.  
Adding a new, custom type named after the `Type` field below, then adding an item of `item type` with the name `item name` allows you to control that particular custom element.

| What?                              | Type         | Item type | Item name          |
|------------------------------------|--------------|-----------|--------------------|
| The background color of the window | `MainWindow` | Color     | `background_color` |
