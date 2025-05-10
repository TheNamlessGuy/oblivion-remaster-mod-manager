class_name BoolSettingsDropdown
extends SettingsDropdown

@export_group("Boolean settings")
@export var true_name := "Yes"
@export_multiline var true_tooltip := ""
@export var false_name := "No"
@export_multiline var false_tooltip := ""

const TRUE := 0
const FALSE := 1

func save(write: bool = true) -> void: Config.set_by_key(config_key, value() == TRUE, write)

func _config_value() -> int:
  var v: Variant = Config.get_by_key(config_key)
  if v == null:
    return -1
  return TRUE if v else FALSE

func _add_items() -> void:
  _dropdown.add_item(true_name)
  _dropdown.set_item_tooltip(TRUE, true_tooltip)

  _dropdown.add_item(false_name)
  _dropdown.set_item_tooltip(FALSE, false_tooltip)
