extends Node

# For typing
enum Key {
  UNKNOWN          = -1,

  BACKGROUND_COLOR = 0,
}

# For usage
const UNKNOWN = ThemeManager.Key.UNKNOWN
const BACKGROUND_COLOR = ThemeManager.Key.BACKGROUND_COLOR

func color(key: ThemeManager.Key, for_node: Control) -> Color:
  return for_node.get_theme_color(_enum_key_to_str(key), for_node.get_name())

func _ready() -> void:
  var path = Global.get_manager_subpath("theme.tres")
  if FileSystem.is_file(path):
    var theme = load(path)
    var children = get_tree().get_root().get_children()
    for child in children:
      if child is MainWindow:
        child.theme = theme

func _enum_key_to_str(key: ThemeManager.Key) -> String:
  return ThemeManager.Key.find_key(key).to_lower()
