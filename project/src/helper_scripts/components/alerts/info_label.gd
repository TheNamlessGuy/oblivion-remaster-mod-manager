class_name InfoLabel
extends Label

func _ready() -> void:
  add_theme_color_override("font_color", ThemeManager.color(ThemeManager.FOREGROUND_COLOR, self))
