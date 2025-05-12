class_name BaseChoiceDialog
extends BaseDialog

var _label := Label.new()
var _button_container := HBoxContainer.new()

func _initialize() -> void:
  super._initialize()

  _label.autowrap_mode = TextServer.AUTOWRAP_OFF
  _label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
  _label.size_flags_vertical = Control.SIZE_SHRINK_CENTER

  _button_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  _button_container.add_child(ExpandedHSplitContainer.new())

func _add_container_children() -> void:
  _container.add_child(_label)
  _add_container_children_after_label()
  _container.add_child(ExpandedVSplitContainer.new())
  _container.add_child(HSeparator.new())
  _add_container_children_before_buttons()
  _container.add_child(_button_container)

## Override in child classes as needed
func _add_container_children_after_label() -> void:
  pass

## Override in child classes as needed
func _add_container_children_before_buttons() -> void:
  pass

func _set_text(text: Array) -> void:
  _label.text = Global.array_to_string(text)

func _add_button(text: String) -> Button:
  var button := Button.new()
  button.text = text

  _button_container.add_child(button)
  _button_container.add_child(ExpandedHSplitContainer.new())

  return button
