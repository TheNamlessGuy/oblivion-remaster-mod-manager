class_name ModDeactivatedConflictChoiceDialog
extends BaseFileConflictChoiceDialog

func for_mod(mod_status: ModStatus.Value, mod: String, conflicting_path: Array) -> void:
  if mod_status == ModStatus.REGULAR:
    _set_text(["Tried to deactivate '", mod, "', but there's already something at the following paths:"])
    _path_label.text = "\n".join(conflicting_path)
  elif mod_status == ModStatus.COPY_ON_ACTIVATION:
    _set_text(["Tried to deactivate '", mod, "', but the original copied from file(s) no longer exists"])

func _init() -> void:
  super._init()

  _add_mod_deactivated_conflict_button(ModDeactivatedConflict.LEAVE)
  _add_mod_deactivated_conflict_button(ModDeactivatedConflict.MOVE_BACK)
  _add_mod_deactivated_conflict_button(ModDeactivatedConflict.REMOVE)

func _add_mod_deactivated_conflict_button(id: ModDeactivatedConflict.Value) -> void:
  _add_file_conflict_choice_button(id, ModDeactivatedConflict.id_to_title(id), ModDeactivatedConflict.id_to_tooltip(id))
