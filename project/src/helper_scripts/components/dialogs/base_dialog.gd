class_name BaseDialog
extends Window

signal closing()

func open(parent: Node) -> void:
  parent.add_child(self)

  var window_size = DisplayServer.window_get_size()
  min_size = window_size / 2
  max_size = window_size - Vector2i(25, 25) # TODO: Better

  popup_centered()

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
  margin_container.set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT)
  scroll_container.add_child(margin_container)

  _container.size_flags_vertical = Control.SIZE_EXPAND_FILL
  _container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  _container.set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT)
  margin_container.add_child(_container)

  close_requested.connect(_close)

func _label_with_text(text: String) -> Label:
  var label := Label.new()
  label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
  label.text = text
  label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  return label

func _close() -> void:
  closing.emit()
  get_parent().remove_child(self)
  queue_free()

func _hide_close_button() -> void:
  # See https://forum.godotengine.org/t/is-there-a-way-to-hide-the-x-button-on-windowdialog/4523
  add_theme_icon_override("close", ImageTexture.new())
