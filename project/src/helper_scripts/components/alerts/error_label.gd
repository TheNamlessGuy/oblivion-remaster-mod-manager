class_name ErrorLabel
extends Label

func _ready() -> void:
  add_theme_color_override("font_color", ThemeManager.color("foreground_color", self))
