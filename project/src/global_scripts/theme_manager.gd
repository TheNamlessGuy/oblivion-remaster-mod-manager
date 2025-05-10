extends Node

# For typing
enum Key {
  UNKNOWN                      = -1,

  BACKGROUND_COLOR             = 0,
  FOREGROUND_COLOR             = 1,

  MOD_TYPE__COPY_ON_ACTIVATION = 2,
  MOD_TYPE__NOT_FOUND          = 3,
  MOD_TYPE__REGULAR            = 4,
  MOD_TYPE__UNMANAGEABLE       = 5,
}

# For usage
const UNKNOWN = ThemeManager.Key.UNKNOWN
const BACKGROUND_COLOR = ThemeManager.Key.BACKGROUND_COLOR
const FOREGROUND_COLOR = ThemeManager.Key.FOREGROUND_COLOR
const MOD_TYPE__COPY_ON_ACTIVATION = ThemeManager.Key.MOD_TYPE__COPY_ON_ACTIVATION
const MOD_TYPE__NOT_FOUND = ThemeManager.Key.MOD_TYPE__NOT_FOUND
const MOD_TYPE__REGULAR = ThemeManager.Key.MOD_TYPE__REGULAR
const MOD_TYPE__UNMANAGEABLE = ThemeManager.Key.MOD_TYPE__UNMANAGEABLE

func color(key: ThemeManager.Key, for_node: Control) -> Color:
  var key_str = _enum_key_to_str(key)
  var script = for_node.get_script()
  while script != null:
    var script_name = script.get_global_name()
    if for_node.has_theme_color(key_str, script_name):
      return for_node.get_theme_color(key_str, script_name)

    script = script.get_base_script()

  Log.debug(Log.error, ["Couldn't find color '", key_str, "' for node '", for_node, "'"])
  return Color.BLACK

func _ready() -> void:
  # If there's a custom theme present, replace the built-in one set on MainWindow
  var path = Global.get_manager_subpath("theme.tres")
  if FileSystem.is_file(path):
    var theme = load(path)
    var children = get_tree().get_root().get_children()
    for child in children:
      if child is MainWindow:
        child.theme = theme
        break

func _enum_key_to_str(key: ThemeManager.Key) -> String:
  return ThemeManager.Key.find_key(key).to_lower()
