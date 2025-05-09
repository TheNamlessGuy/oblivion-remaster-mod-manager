@tool
class_name ModDeactivatedConflictSettingsDropdown
extends SettingsDropdown

@export_group("ModDeactivatedConflict settings")
@export_subgroup("Leave")
@export var leave_enabled: bool = true
@export var leave_text: String = ModDeactivatedConflict.id_to_title(ModDeactivatedConflict.LEAVE)
@export_multiline var leave_tooltip: String = ModDeactivatedConflict.id_to_tooltip(ModDeactivatedConflict.LEAVE)

@export_subgroup("Move back")
@export var move_back_enabled: bool = true
@export var move_back_text: String = ModDeactivatedConflict.id_to_title(ModDeactivatedConflict.MOVE_BACK)
@export_multiline var move_back_tooltip: String = ModDeactivatedConflict.id_to_tooltip(ModDeactivatedConflict.MOVE_BACK)

@export_subgroup("Remove")
@export var remove_enabled: bool = true
@export var remove_text: String = ModDeactivatedConflict.id_to_title(ModDeactivatedConflict.REMOVE)
@export_multiline var remove_tooltip: String = ModDeactivatedConflict.id_to_tooltip(ModDeactivatedConflict.REMOVE)

func _add_items() -> void:
  _dropdown.add_item(leave_text)
  _dropdown.set_item_tooltip(ModDeactivatedConflict.LEAVE, leave_tooltip)
  _dropdown.set_item_disabled(ModDeactivatedConflict.LEAVE, not leave_enabled)

  _dropdown.add_item(move_back_text)
  _dropdown.set_item_tooltip(ModDeactivatedConflict.MOVE_BACK, move_back_tooltip)
  _dropdown.set_item_disabled(ModDeactivatedConflict.MOVE_BACK, not move_back_enabled)

  _dropdown.add_item(remove_text)
  _dropdown.set_item_tooltip(ModDeactivatedConflict.REMOVE, remove_tooltip)
  _dropdown.set_item_disabled(ModDeactivatedConflict.REMOVE, not remove_enabled)
