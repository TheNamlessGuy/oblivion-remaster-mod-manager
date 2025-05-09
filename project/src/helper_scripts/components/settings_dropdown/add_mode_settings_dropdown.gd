class_name AddModeSettingsDropdown
extends SettingsDropdown

@export_group("AddMode settings")
@export_subgroup("Move on add")
@export var move_on_add_enabled: bool = true
@export var move_on_add_text: String = AddMode.id_to_title(AddMode.MOVE_ON_ADD)
@export_multiline var move_on_add_tooltip: String = AddMode.id_to_tooltip(AddMode.MOVE_ON_ADD)

@export_subgroup("Copy on activation")
@export var copy_on_activation_enabled: bool = true
@export var copy_on_activation_text: String = AddMode.id_to_title(AddMode.COPY_ON_ACTIVATION)
@export_multiline var copy_on_activation_tooltip: String = AddMode.id_to_tooltip(AddMode.COPY_ON_ACTIVATION)

func _add_items() -> void:
  _dropdown.add_item(move_on_add_text)
  _dropdown.set_item_tooltip(AddMode.MOVE_ON_ADD, move_on_add_tooltip)
  _dropdown.set_item_disabled(AddMode.MOVE_ON_ADD, not move_on_add_enabled)

  _dropdown.add_item(copy_on_activation_text)
  _dropdown.set_item_tooltip(AddMode.COPY_ON_ACTIVATION, copy_on_activation_tooltip)
  _dropdown.set_item_disabled(AddMode.COPY_ON_ACTIVATION, not copy_on_activation_enabled)
