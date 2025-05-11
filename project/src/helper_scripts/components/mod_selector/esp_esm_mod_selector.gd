class_name EspEsmModSelector
extends BaseModSelector

const _ACTIVE_INTERNAL_FILES := [
  "Oblivion.esm",
  "DLCBattlehornCastle.esp",
  "DLCFrostcrag.esp",
  "DLCHorseArmor.esp",
  "DLCMehrunesRazor.esp",
  "DLCOrrery.esp",
  "DLCShiveringIsles.esp",
  "DLCSpellTomes.esp",
  "DLCThievesDen.esp",
  "DLCVileLair.esp",
  "Knights.esp",
  "AltarESPMain.esp",
  "AltarDeluxe.esp",
  "AltarESPLocal.esp",
]

const _INACTIVE_INTERNAL_FILES := [
  "AltarGymNavigation.esp",
  "TamrielLeveledRegion.esp",
]

const _INTERNAL_FILES := _ACTIVE_INTERNAL_FILES + _INACTIVE_INTERNAL_FILES

func _custom_setup() -> void:
  add_file_dialog.add_filter("*.esp, *.esm", "Mod files")

## Returns the full path of the Plugins.txt file
func _get_plugin_file_path() -> String:
  return FileSystem.path([Game.get_data_dir(), "Plugins.txt"])

func _read_active_mods_from_fs() -> Array:
  return FileSystem.read_lines(_get_plugin_file_path()).filter(func(mod: String) -> bool:
    return mod not in _INTERNAL_FILES
  )

func _active_mod_is_not_found(mod: String) -> bool:
  return not FileSystem.exists(FileSystem.path([Game.get_data_dir(), mod]))

func _other_available_mod_is_not_found(_mod: String) -> bool:
  return false # Can't be, since they're all fetched directly from the file system

func _read_other_available_mods_from_fs() -> Array:
  return FileSystem.files_in(Game.get_data_dir()).filter(func(file: String) -> bool:
    if not file.ends_with(".esp") and not file.ends_with(".esm"):
      return false
    elif file in _INTERNAL_FILES:
      return false
    elif _active_mod_exists(file, false):
      return false

    return true
  )

func _get_mod_name_from_file(file: String) -> String:
  return FileSystem.get_filename(file)

func _persist_mod_file_addition(mod: String, file: String, add_mode: AddMode.Value) -> void:
  if add_mode == AddMode.MOVE_ON_ADD:
    FileSystem.move(file, FileSystem.path([Game.get_data_dir(), mod]), true)
  elif add_mode == AddMode.COPY_ON_ACTIVATION:
    CopyOnActivationMods.add_for_mod_type(mod_type, mod, file)
  else:
    Global.fatal_error(["Encountered unknown AddMode '", add_mode, "' in EspEsmModSelector::_persist_file_addition"])

func _on_regular_mod_deletion(mod: String) -> void:
  var path := FileSystem.path([Game.get_data_dir(), mod])
  if FileSystem.is_file(path):
    FileSystem.trash(path)

func _available_copy_on_activation_mod_is_not_found(mod: String) -> bool:
  var copy_from_path_exists := CopyOnActivationMods.path_for_mod_exists(mod_type, mod)
  var copied_to_path_exists := FileSystem.is_file(FileSystem.path([Game.get_data_dir(), mod]))
  return not copy_from_path_exists and not copied_to_path_exists

func _active_mod_is_unmanageable(_mod: String) -> bool:
  return false # There's no such state for ESP/ESM

# START: Save section

func _perform_save_on_deactivated_regular_mod(_mod: String, _diffs: Dictionary, _remembered_choices: Dictionary) -> bool:
  return false # There's nothing to do here

func _perform_save_on_deactivated_copy_on_activation_mod(mod: String, diffs: Dictionary, remembered_choices: Dictionary) -> bool:
  var mod_file := FileSystem.path([Game.get_data_dir(), mod])
  var old_file := CopyOnActivationMods.get_path_for_mod(mod_type, mod)

  var save_type := ModDiffType.DEACTIVATED_COPY_ON_ACTIVATION
  var remembered_choice: ModDeactivatedConflict.Value = remembered_choices[save_type]
  var callback := _resolve_perform_save_on_deactivated_copy_on_activation_mod_conflict.bind(mod_file, old_file)

  if FileSystem.exists(old_file): # No conflict
    FileSystem.trash(mod_file)
    return false
  elif remembered_choice != ModDeactivatedConflict.UNKNOWN:
    callback.call(remembered_choice)
    return false

  var prompt := ModDeactivatedConflictChoiceDialog.new()
  prompt.for_mod(ModStatus.COPY_ON_ACTIVATION, mod, old_file)
  prompt.choice_made.connect(_on_save_conflict_prompt_response.bind(save_type, callback, diffs, remembered_choices))
  prompt.open(self)
  return true

func _resolve_perform_save_on_deactivated_copy_on_activation_mod_conflict(action: ModDeactivatedConflict.Value, mod_file: String, old_file: String) -> void:
  if action == ModDeactivatedConflict.LEAVE:
    pass # Don't do anything
  elif action == ModDeactivatedConflict.MOVE_BACK:
    FileSystem.copy(mod_file, old_file, true)
  elif action == ModDeactivatedConflict.REMOVE:
    FileSystem.trash(mod_file)
  else:
    Global.fatal_error(["Encountered unknown ModDeactivatedConflict '", action, "' in EspEsmModSelector::_resolve_perform_save_on_deactivated_copy_on_activation_mod_conflict"])

func _perform_save_on_deactivated_not_found_mod(_mod: String, _diffs: Dictionary, _remembered_choices: Dictionary) -> bool:
  return false # There's nothing to do here

func _perform_save_on_activated_regular_mod(_mod: String, _diffs: Dictionary, _remembered_choices: Dictionary) -> bool:
  return false # There's nothing to do here

func _perform_save_on_activated_copy_on_activation_mod(mod: String, diffs: Dictionary, remembered_choices: Dictionary) -> bool:
  var from := CopyOnActivationMods.get_path_for_mod(mod_type, mod)
  var to := FileSystem.path([Game.get_data_dir(), mod])

  var save_type := ModDiffType.ACTIVATED_COPY_ON_ACTIVATION
  var remembered_choice: ModActivatedConflict.Value = remembered_choices[save_type]
  var callback := _resolve_perform_save_on_activated_copy_on_activation_mod_conflict.bind(from, to)

  if not FileSystem.exists(to): # No conflict
    FileSystem.copy(from, to, true)
    return false
  elif remembered_choice != ModActivatedConflict.UNKNOWN:
    callback.call(remembered_choice)
    return false

  var prompt := ModActivatedConflictChoiceDialog.new()
  prompt.for_mod(from, to)
  prompt.choice_made.connect(_on_save_conflict_prompt_response.bind(save_type, callback, diffs, remembered_choices))
  prompt.open(self)
  return true

func _resolve_perform_save_on_activated_copy_on_activation_mod_conflict(action: ModActivatedConflict.Value, from: String, to: String) -> void:
  if action == ModActivatedConflict.DEACTIVATE:
    pass # Don't do anything
  elif action == ModActivatedConflict.REPLACE:
    FileSystem.copy(from, to, true)
  else:
    Global.fatal_error(["Encountered unknown ModActivatedConflict '", action, "' in EspEsmModSelector::_resolve_perform_save_on_activated_copy_on_activation_mod_conflict"])

func _perform_save_on_activated_not_found_mod(_mod: String, _diffs: Dictionary, _remembered_choices: Dictionary) -> bool:
  return false # There's nothing to do here

func _custom_post_save_actions() -> void:
  # Write active_mod_list to Plugins.txt
  FileSystem.write_lines(_get_plugin_file_path(), _ACTIVE_INTERNAL_FILES + _mod_list_to_array(active_mods_list))

# END: Save section
