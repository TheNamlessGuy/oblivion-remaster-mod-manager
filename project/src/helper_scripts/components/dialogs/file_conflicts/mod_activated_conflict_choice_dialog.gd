class_name ModActivatedConflictChoiceDialog
extends BaseFileConflictChoiceDialog

func for_mod(_status: ModStatus.Value, mod: String, conflicting_path: Array) -> void:
  _set_text(["Tried to activate '", mod, "', but there's already things at the following paths:"])
  _path_label.text = "\n".join(conflicting_path)

func _init() -> void:
  super._init()

  _add_mod_activated_conflict_button(ModActivatedConflict.DEACTIVATE)
  _add_mod_activated_conflict_button(ModActivatedConflict.REPLACE)

func _add_mod_activated_conflict_button(id: ModActivatedConflict.Value) -> void:
  _add_file_conflict_choice_button(id, ModActivatedConflict.id_to_title(id), ModActivatedConflict.id_to_tooltip(id))
