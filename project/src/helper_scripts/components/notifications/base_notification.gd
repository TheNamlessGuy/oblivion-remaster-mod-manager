class_name BaseNotification
extends PanelContainer

## It's up to child classes to emit this
@warning_ignore("unused_signal")
signal dying()

func set_title(to: String) -> void:
  _title.text = to
  _title.visible = true

var _container := VBoxContainer.new()
var _title := Label.new()
var _border := ColorRect.new()
var _background := ColorRect.new()

func _ready() -> void:
  _border.color = ThemeManager.color("body_border_color", self)
  _background.color = ThemeManager.color("body_background_color", self)

func _init() -> void:
  _border.set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT)
  add_child(_border)

  var actual_container := VBoxContainer.new()
  actual_container.set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT)
  add_child(actual_container)

  _add_children_above_title(actual_container)

  var title_margin := MarginContainer.new()
  title_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
  title_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  title_margin.add_theme_constant_override("margin_top", 0)
  title_margin.add_theme_constant_override("margin_bottom", 0)
  actual_container.add_child(title_margin)

  _title.visible = false
  title_margin.add_child(_title)

  var body_margin := MarginContainer.new()
  body_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
  body_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  body_margin.add_theme_constant_override("margin_top", 0)
  actual_container.add_child(body_margin)

  _background.set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT)
  body_margin.add_child(_background)

  var container_margin := MarginContainer.new()
  container_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
  container_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  body_margin.add_child(container_margin)

  container_margin.add_child(_container)

  _initialize()
  _add_container_children()

## Override in child classes as needed
func _initialize() -> void:
  pass

## Override in child classes as needed
func _add_container_children() -> void:
  pass

## Override in child classes as needed
func _start() -> void:
  pass

## Override in child classes as needed
func _add_children_above_title(_c: Control) -> void:
  pass

func _parent() -> NotificationContainer:
  return get_parent().get_parent()
