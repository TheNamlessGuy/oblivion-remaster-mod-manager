class_name BaseDialog
extends Window

signal closing()

func open(parent: Node) -> void:
  parent.add_child(self)

  var decoration_size = get_size_with_decorations() - size
  max_size = DisplayServer.window_get_size() - (decoration_size * 2)

  popup_centered()

  var _on_container_resized = func(listener: Callable) -> void:
    if _container.resized.is_connected(listener):
      _container.resized.disconnect(listener)

    var margin_container: MarginContainer = _container.get_parent()
    var scroll_container: ScrollContainer = margin_container.get_parent()

    margin_container.reset_size()
    size = margin_container.size + scroll_container.get_h_scroll_bar().size
    move_to_center()

  _container.resized.connect(_on_container_resized.bind(_on_container_resized))
  _on_container_resized.call(func() -> void: pass)

var _container := VBoxContainer.new()

func _init() -> void:
  transient = true
  exclusive = true
  wrap_controls = true

  var scroll_container := ScrollContainer.new()
  scroll_container.set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT)
  add_child(scroll_container)

  var margin_container := MarginContainer.new()
  margin_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
  margin_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  scroll_container.add_child(margin_container)

  _container.alignment = BoxContainer.ALIGNMENT_CENTER
  _container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
  _container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  margin_container.add_child(_container)

  close_requested.connect(_close)

  _initialize()
  _add_container_children()

## Override in child classes as needed
func _initialize() -> void:
  pass

## Override in child classes as needed
func _add_container_children() -> void:
  pass

func _close() -> void:
  closing.emit()

  var parent = get_parent()
  if parent:
    parent.remove_child(self)

  queue_free()

func _hide_close_button() -> void:
  # See https://forum.godotengine.org/t/is-there-a-way-to-hide-the-x-button-on-windowdialog/4523
  add_theme_icon_override("close", ImageTexture.new())
