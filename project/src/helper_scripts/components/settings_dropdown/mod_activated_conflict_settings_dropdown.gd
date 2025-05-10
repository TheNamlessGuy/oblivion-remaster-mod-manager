class_name ModActivatedConflictSettingsDropdown
extends SettingsDropdown

@export_group("ModActivatedConflict settings")
@export_subgroup("Deactivate")
@export var deactivate_enabled: bool = true
@export var deactivate_text: String = ModActivatedConflict.id_to_title(ModActivatedConflict.DEACTIVATE)
@export_multiline var deactivate_tooltip: String = ModActivatedConflict.id_to_tooltip(ModActivatedConflict.DEACTIVATE)

@export_subgroup("Replace")
@export var replace_enabled: bool = true
@export var replace_text: String = ModActivatedConflict.id_to_title(ModActivatedConflict.REPLACE)
@export_multiline var replace_tooltip: String = ModActivatedConflict.id_to_tooltip(ModActivatedConflict.REPLACE)

@export_subgroup("Prompt")
@export var prompt_enabled: bool = true
@export var prompt_text: String = ModActivatedConflict.id_to_title(ModActivatedConflict.PROMPT)
@export_multiline var prompt_tooltip: String = ModActivatedConflict.id_to_tooltip(ModActivatedConflict.PROMPT)

func _add_items() -> void:
  _dropdown.add_item(deactivate_text)
  _dropdown.set_item_tooltip(ModActivatedConflict.DEACTIVATE, deactivate_tooltip)
  _dropdown.set_item_disabled(ModActivatedConflict.DEACTIVATE, not deactivate_enabled)

  _dropdown.add_item(replace_text)
  _dropdown.set_item_tooltip(ModActivatedConflict.REPLACE, replace_tooltip)
  _dropdown.set_item_disabled(ModActivatedConflict.REPLACE, not replace_enabled)

  _dropdown.add_item(prompt_text)
  _dropdown.set_item_tooltip(ModActivatedConflict.PROMPT, prompt_tooltip)
  _dropdown.set_item_disabled(ModActivatedConflict.PROMPT, not prompt_enabled)
