class_name AddModConflictSettingsDropdown
extends SettingsDropdown

@export_group("AddModConflict settings")
@export_subgroup("Skip")
@export var skip_enabled: bool = true
@export var skip_text: String = AddModConflict.id_to_title(AddModConflict.SKIP)
@export_multiline var skip_tooltip: String = AddModConflict.id_to_tooltip(AddModConflict.SKIP)

@export_subgroup("Replace")
@export var replace_enabled: bool = true
@export var replace_text: String = AddModConflict.id_to_title(AddModConflict.REPLACE)
@export_multiline var replace_tooltip: String = AddModConflict.id_to_tooltip(AddModConflict.REPLACE)

func _add_items() -> void:
  _dropdown.add_item(skip_text)
  _dropdown.set_item_tooltip(AddModConflict.SKIP, skip_tooltip)
  _dropdown.set_item_disabled(AddModConflict.SKIP, not skip_enabled)

  _dropdown.add_item(replace_text)
  _dropdown.set_item_tooltip(AddModConflict.REPLACE, replace_tooltip)
  _dropdown.set_item_disabled(AddModConflict.REPLACE, not replace_enabled)
