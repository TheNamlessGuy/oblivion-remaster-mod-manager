extends Node

func color(key: String, for_node: Control) -> Color:
  var script: Variant = for_node.get_script()
  while script != null:
    var script_name: StringName = script.get_global_name()
    if for_node.has_theme_color(key, script_name):
      return for_node.get_theme_color(key, script_name)

    script = script.get_base_script()

  Log.debug(Log.error, ["Couldn't find color '", key, "' for node '", for_node, "'"])
  return Color.BLACK

func _ready() -> void:
  # If there's a custom theme present, replace the built-in one set on MainWindow
  var path := Global.get_manager_subpath("theme.tres")
  if FileSystem.is_file(path):
    var theme := load(path)
    var children := get_tree().get_root().get_children()
    for child in children:
      if child is MainWindow:
        child.theme = theme
        break
