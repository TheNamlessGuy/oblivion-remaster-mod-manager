@tool
class_name AlertContainer
extends VBoxContainer

func clear() -> void:
  hide()

  var children := get_children()
  for child in children:
    remove_child(child)

func empty() -> bool: return get_child_count() == 0
func has_errors() -> bool:
  var children := get_children()
  for child in children:
    if child is ErrorLabel:
      return true

  return false

func error(msg: Array) -> void:
  _add_alert(msg, ErrorLabel.new())

func warning(msg: Array) -> void:
  _add_alert(msg, WarningLabel.new())

func info(msg: Array) -> void:
  _add_alert(msg, InfoLabel.new())

func _enter_tree() -> void:
  if Engine.is_editor_hint():
    visible = false

enum SeparatorMode {
  EVERY_TIME = 0,
  IN_BETWEEN = 1,
  NEVER = 2,
}

@export var separator_mode: SeparatorMode = SeparatorMode.EVERY_TIME

func _add_alert(msg: Array, label: Label) -> void:
  if separator_mode == SeparatorMode.IN_BETWEEN and get_child_count() > 0:
    _add_separator()

  label.text = Global.array_to_string(msg)
  label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

  add_child(label)

  if separator_mode == SeparatorMode.EVERY_TIME:
    _add_separator()

  show()

func _add_separator() -> void:
  add_child(HSeparator.new())
