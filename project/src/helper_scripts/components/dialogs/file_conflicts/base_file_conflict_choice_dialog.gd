class_name BaseFileConflictChoiceDialog
extends BaseChoiceDialog

signal choice_made(value: int, remember: bool)

var _path_label := Label.new()

var _remember_checkbox := CheckBox.new()
var _remember_container := HBoxContainer.new()

func _initialize() -> void:
  super._initialize()

  title = "File conflict encountered"
  _hide_close_button()

  _label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN

  _path_label.text = ""
  _path_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
  _path_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  _path_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER

  _remember_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
  _remember_container.add_child(_remember_checkbox)

  var remember_label := Label.new()
  remember_label.autowrap_mode = TextServer.AUTOWRAP_OFF
  remember_label.text = "Remember my choice for the next similar conflict during this save process"
  remember_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  _remember_container.add_child(remember_label)

func _add_container_children_after_label() -> void:
  _container.add_child(_path_label)

func _add_container_children_before_buttons() -> void:
  _container.add_child(_remember_container)

func _set_text(text: Array) -> void:
  _label.text = Global.array_to_string(text)

func _add_file_conflict_choice_button(value: int, text: String, tooltip: String = "") -> Button:
  var button := _add_button(text)
  button.tooltip_text = tooltip
  button.button_up.connect(_on_button_pressed.bind(value))
  return button

func _on_button_pressed(value: int) -> void:
  choice_made.emit(value, _remember_checkbox.button_pressed)
  _close()
