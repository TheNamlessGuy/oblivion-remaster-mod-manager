@tool
class_name WarningLabel
extends Label

func _ready() -> void:
  add_theme_color_override("font_color", Color.YELLOW)
