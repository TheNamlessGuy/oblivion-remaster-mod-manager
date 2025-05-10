class_name AddModConflictChoiceDialog
extends BaseChoiceDialog

func for_mod(mod: String) -> void:
  _set_text(["Tried adding mod '", mod, "', but there's already a mod by that name existing"])

func _init() -> void:
  super._init()

  _add_add_mod_conflict_button(AddModConflict.SKIP)
  _add_add_mod_conflict_button(AddModConflict.REPLACE)

func _add_add_mod_conflict_button(id: AddModConflict.Value) -> void:
  _add_button(id, AddModConflict.id_to_title(id), AddModConflict.id_to_tooltip(id))
