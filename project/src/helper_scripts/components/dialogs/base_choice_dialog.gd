class_name BaseChoiceDialog
extends BaseDialog

signal choice_made(value: int, remember: bool)

var _label := Label.new()
var _button_container := HBoxContainer.new()
var _remember_checkbox := CheckBox.new()

func _init() -> void:
  super._init()

  title = "File conflict encountered"
  _hide_close_button()

  _label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
  _container.add_child(_label)

  var vsplit := VSplitContainer.new()
  vsplit.size_flags_vertical = Control.SIZE_EXPAND_FILL
  _container.add_child(vsplit)

  var remember_container := HBoxContainer.new()
  remember_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  remember_container.add_child(_remember_checkbox)
  remember_container.add_child(_label_with_text("Remember my choice for the next similar conflict during this save process"))
  _container.add_child(remember_container)

  _container.add_child(HSeparator.new())

  _button_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  _button_container.add_child(_expanded_h_split_container())
  _container.add_child(_button_container)

func _set_text(text: Array) -> void:
  _label.text = Global.array_to_string(text)

func _add_button(value: int, text: String, tooltip: String = "") -> void:
  var button := Button.new()
  button.text = text
  button.tooltip_text = tooltip
  button.button_up.connect(_on_button_pressed.bind(value))

  _button_container.add_child(button)
  _button_container.add_child(_expanded_h_split_container())

func _expanded_h_split_container() -> HSplitContainer:
  var container := HSplitContainer.new()
  container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  return container

func _on_button_pressed(value: int) -> void:
  choice_made.emit(value, _remember_checkbox.button_pressed)
  _close()
