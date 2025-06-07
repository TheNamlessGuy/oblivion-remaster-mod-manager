class_name NPCAppearanceManagerModSelector
extends BaseModSelector

func _custom_prerequisites_checks() -> void:
  if not UE4SSHelper.is_active():
    alert_container.info(["UE4SS needs to be installed for NPCAppearanceManager mods to work"])
  elif not UE4SSHelper.mod_is_active("NPCAppearanceManager"):
    alert_container.info(["NPCAppearanceManager doesn't seem to be installed correctly. Please make sure it is, then come back and press 'Reload'"])

func _custom_setup() -> void:
  add_file_dialog.add_filter("*.json", "Mod files")

func _read_active_mods_from_fs() -> Array:
  return FileSystem.files_in(_mod_dir()).filter(func(mod: String) -> bool:
    return mod.ends_with(".json")
  ).map(func(file: String) -> String:
    return _get_mod_name_from_file(file)
  )

func _read_other_available_mods_from_fs() -> Array:
  var dir := Config.npc_appearance_manager_available_mods_folder
  if not FileSystem.is_dir(dir):
    return []

  var mods: Array[String] = []
  var files := FileSystem.files_in(dir)
  for file in files:
    if not file.ends_with(".json"): continue

    var mod := _get_mod_name_from_file(file)
    if not _active_mod_exists(mod, false):
      mods.push_back(mod)

  return mods

func _get_active_paths_for_mod(mod: String) -> Array:
  return [_get_active_path_for_mod(mod)]

func _convert_active_paths_to_available(mod: String, active_paths: Array, status: ModStatus.Value) -> Array:
  if status == ModStatus.REGULAR:
    return FileSystem.get_paths_with_swapped_directories(active_paths, _mod_dir(), Config.npc_appearance_manager_available_mods_folder)
  elif status == ModStatus.COPY_ON_ACTIVATION:
    return FileSystem.get_paths_with_swapped_directories(active_paths, _mod_dir(), CopyOnActivationMods.get_parent_dir_for_mod(mod_type, mod))
  else:
    Global.fatal_error(["Unknown status '", status, "' encountered in NPCAppearanceManagerModSelector::_convert_active_paths_to_available"])
    return []

func _get_available_paths_for_mod(mod: String, status: ModStatus.Value) -> Array:
  if status == ModStatus.REGULAR:
    return [_get_available_regular_path_for_mod(mod)]
  elif status == ModStatus.COPY_ON_ACTIVATION:
    return [CopyOnActivationMods.get_path_for_mod(mod_type, mod)]
  else:
    Global.fatal_error(["Unknown status '", status, "' encountered in NPCAppearanceManagerModSelector::_get_available_paths_for_mod"])
    return []

func _convert_available_paths_to_active(mod: String, available_paths: Array, status: ModStatus.Value) -> Array:
  if status == ModStatus.REGULAR:
    return FileSystem.get_paths_with_swapped_directories(available_paths, Config.npc_appearance_manager_available_mods_folder, _mod_dir())
  elif status == ModStatus.COPY_ON_ACTIVATION:
    return FileSystem.get_paths_with_swapped_directories(available_paths, CopyOnActivationMods.get_parent_dir_for_mod(mod_type, mod), _mod_dir())
  else:
    Global.fatal_error(["Unknown status '", status, "' encountered in NPCAppearanceManagerModSelector::_convert_available_paths_to_active"])
    return []

func _other_available_mod_is_not_found(mod: String) -> bool:
  return not FileSystem.is_file(_get_available_regular_path_for_mod(mod))

func _active_mod_is_unmanageable(_mod: String) -> bool:
  return false # No such use-case

func _get_mod_name_from_file(file: String) -> String:
  return FileSystem.get_filename(file, [".json"])

func _persist_mod_file_addition(mod: String, file: String, add_mode: AddMode.Value) -> void:
  if add_mode == AddMode.MOVE_ON_ADD:
    var to_path := FileSystem.path([Config.npc_appearance_manager_available_mods_folder, FileSystem.get_filename(file)])
    FileSystem.move(file, to_path, true)
  elif add_mode == AddMode.COPY_ON_ACTIVATION:
    CopyOnActivationMods.add_for_mod_type(mod_type, mod, file)
  else:
    Global.fatal_error(["Encountered unknown AddMode '", add_mode, "' in NPCAppearanceManagerModSelector::_persist_mod_file_addition"])

func _mod_dir() -> String:
  return FileSystem.path([UE4SSHelper.get_active_mod_dir("NPCAppearanceManager"), "NPC"])

func _get_filename_from_mod(mod: String) -> String: return mod + ".json"
func _get_active_path_for_mod(mod: String) -> String: return FileSystem.path([_mod_dir(), _get_filename_from_mod(mod)])
func _get_available_regular_path_for_mod(mod: String) -> String: return FileSystem.path([Config.npc_appearance_manager_available_mods_folder, _get_filename_from_mod(mod)])
