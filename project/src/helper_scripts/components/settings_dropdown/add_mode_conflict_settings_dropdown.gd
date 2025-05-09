class_name AddModeConflictSettingsDropdown
extends SettingsDropdown

@export_group("AddModeConflict settings")
@export_subgroup("Skip")
@export var skip_enabled: bool = true
@export var skip_text: String = AddModeConflict.id_to_title(AddModeConflict.SKIP)
@export_multiline var skip_tooltip: String = AddModeConflict.id_to_tooltip(AddModeConflict.SKIP)

@export_subgroup("Replace")
@export var replace_enabled: bool = true
@export var replace_text: String = AddModeConflict.id_to_title(AddModeConflict.REPLACE)
@export_multiline var replace_tooltip: String = AddModeConflict.id_to_tooltip(AddModeConflict.REPLACE)

func _add_items() -> void:
  _dropdown.add_item(skip_text)
  _dropdown.set_item_tooltip(AddModeConflict.SKIP, skip_tooltip)
  _dropdown.set_item_disabled(AddModeConflict.SKIP, not skip_enabled)

  _dropdown.add_item(replace_text)
  _dropdown.set_item_tooltip(AddModeConflict.REPLACE, replace_tooltip)
  _dropdown.set_item_disabled(AddModeConflict.REPLACE, not replace_enabled)
