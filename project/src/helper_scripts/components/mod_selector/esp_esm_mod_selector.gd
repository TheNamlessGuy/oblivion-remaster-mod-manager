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

func _available_copy_on_activation_mod_is_not_found(mod: String) -> bool:
  var copy_from_path_exists := CopyOnActivationMods.path_for_mod_exists(mod_type, mod)
  var copied_to_path_exists := FileSystem.is_file(FileSystem.path([Game.get_data_dir(), mod]))
  return not copy_from_path_exists and not copied_to_path_exists

func _active_mod_is_unmanageable(_mod: String) -> bool:
  return false # There's no such state for ESP/ESM

func _custom_post_save_actions() -> void:
  # Write active_mod_list to Plugins.txt
  FileSystem.write_lines(_get_plugin_file_path(), _ACTIVE_INTERNAL_FILES + _mod_list_to_array(active_mods_list))

func _get_active_paths_for_mod(mod: String) -> Array:
  return [FileSystem.path([Game.get_data_dir(), mod])]

func _convert_active_paths_to_available(mod: String, active_paths: Array, status: ModStatus.Value) -> Array:
  if status == ModStatus.REGULAR:
    return active_paths # No path difference between active and available
  elif status == ModStatus.COPY_ON_ACTIVATION:
    return FileSystem.get_paths_with_swapped_directories(active_paths, Game.get_data_dir(), CopyOnActivationMods.get_parent_dir_for_mod(mod_type, mod))
  else:
    Global.fatal_error(["Unknown status '", status, "' encountered in EspEsmModSelector::_convert_active_paths_to_available"])
    return []

func _get_available_paths_for_mod(mod: String, status: ModStatus.Value) -> Array:
  if status == ModStatus.REGULAR:
    return _get_active_paths_for_mod(mod) # No difference between active and available
  elif status == ModStatus.COPY_ON_ACTIVATION:
    return [CopyOnActivationMods.get_path_for_mod(mod_type, mod)]
  else:
    Global.fatal_error(["Unknown status '", status, "' encountered in EspEsmModSelector::_get_available_paths_for_mod"])
    return []

func _convert_available_paths_to_active(mod: String, available_paths: Array, status: ModStatus.Value) -> Array:
  if status == ModStatus.REGULAR:
    return available_paths # No path difference between active and available
  elif status == ModStatus.COPY_ON_ACTIVATION:
    return FileSystem.get_paths_with_swapped_directories(available_paths, CopyOnActivationMods.get_parent_dir_for_mod(mod_type, mod), Game.get_data_dir())
  else:
    Global.fatal_error(["Unknown status '", status, "' encountered in EspEsmModSelector::_convert_available_paths_to_active"])
    return []
