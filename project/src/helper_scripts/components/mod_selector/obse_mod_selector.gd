class_name OBSEModSelector
extends BaseModSelector

func _custom_setup() -> void:
  # Hide up/down arrows, they make no sense here
  up_button.visible = false
  down_button.visible = false

  add_file_dialog.add_filter("*.dll", "Mod files")

func _custom_prerequisites_checks() -> void:
  var obse_loader_path := FileSystem.path([Game.get_bin_path(), "obse64_loader.exe"])
  if not FileSystem.is_file(obse_loader_path):
    alert_container.info(["Couldn't find 'obse64_loader.exe'. Please make sure OBSE is installed correctly"])

func _activate_mod(mod: String) -> void:
  super._activate_mod(mod)
  active_mods_list.sort_items_by_text()

func _read_active_mods_from_fs() -> Array:
  return _get_mods_in_dir(_get_obse_plugin_folder())

func _read_other_available_mods_from_fs() -> Array:
  var dir := Config.obse_available_mods_folder
  if not FileSystem.is_dir(dir):
    return []

  return _get_mods_in_dir(dir).filter(func(mod: String) -> bool:
    return not _active_mod_exists(mod, false)
  )

func _active_mod_is_not_found(mod: String) -> bool:
  return not FileSystem.is_file(_get_full_path_to_mod_file_in_dir(mod, _get_obse_plugin_folder()))

func _other_available_mod_is_not_found(mod: String) -> bool:
  return not FileSystem.is_file(_get_full_path_to_mod_file_in_dir(mod, Config.obse_available_mods_folder))

func _active_mod_is_unmanageable(_mod: String) -> bool:
  return false # There's no such state for OBSE

func _get_mod_name_from_file(file: String) -> String:
  return FileSystem.get_filename(file, [".dll"])

func _persist_mod_file_addition(mod: String, file: String, add_mode: AddMode.Value) -> void:
  if add_mode == AddMode.MOVE_ON_ADD:
    _fs_move_mod_files_to_dir(mod, FileSystem.get_directory(file), Config.obse_available_mods_folder)
  elif add_mode == AddMode.COPY_ON_ACTIVATION:
    CopyOnActivationMods.add_for_mod_type(mod_type, mod, file)
  else:
    Global.fatal_error(["Encountered unknown AddMode '", add_mode, "' in OBSEModSelector::_persist_mod_file_addition"])

func _get_obse_plugin_folder() -> String:
  return FileSystem.path([Game.get_bin_path(), "OBSE", "Plugins"])

func _get_mods_in_dir(dir: String) -> Array:
  return FileSystem.files_in(dir).filter(func(file: String) -> bool:
    return file.ends_with(".dll")
  ).map(func(file: String) -> String:
    return _get_mod_name_from_file(file)
  )

func _get_full_path_to_mod_file_in_dir(mod: String, dir: String) -> String:
  return FileSystem.path([dir, mod + ".dll"])

## Returns the full path of all the files related to the mod in the given directory
func _fs_read_mod_files_from_dir(mod: String, dir: String) -> Array:
  return FileSystem.files_in(dir).filter(func(file: String) -> bool:
    return file.begins_with(mod + ".")
  ).map(func(file: String) -> String:
    return FileSystem.path([dir, file])
  )

## Moves all the files related to the given mod in from_dir to to_dir
func _fs_move_mod_files_to_dir(mod: String, from_dir: String, to_dir: String) -> void:
  var from_files := _fs_read_mod_files_from_dir(mod, from_dir)
  for from_file in from_files:
    var to_file := FileSystem.path([to_dir, FileSystem.get_filename(from_file)])
    FileSystem.move(from_file, to_file, true)

func _get_active_paths_for_mod(mod: String) -> Array:
  return _fs_read_mod_files_from_dir(mod, _get_obse_plugin_folder())

func _convert_active_paths_to_available(mod: String, active_paths: Array, status: ModStatus.Value) -> Array:
  if status == ModStatus.REGULAR:
    return FileSystem.get_paths_with_swapped_directories(active_paths, _get_obse_plugin_folder(), Config.obse_available_mods_folder)
  elif status == ModStatus.COPY_ON_ACTIVATION:
    return FileSystem.get_paths_with_swapped_directories(active_paths, _get_obse_plugin_folder(), CopyOnActivationMods.get_parent_dir_for_mod(mod_type, mod))
  else:
    Global.fatal_error(["Unknown status '", status, "' encountered in OBSEModSelector::_convert_active_paths_to_available"])
    return []

func _get_available_paths_for_mod(mod: String, status: ModStatus.Value) -> Array:
  if status == ModStatus.REGULAR:
    return _fs_read_mod_files_from_dir(mod, Config.obse_available_mods_folder)
  elif status == ModStatus.COPY_ON_ACTIVATION:
    return _fs_read_mod_files_from_dir(mod, CopyOnActivationMods.get_parent_dir_for_mod(mod_type, mod))
  else:
    Global.fatal_error(["Unknown status '", status, "' encountered in OBSEModSelector::_get_available_paths_for_mod"])
    return []

func _convert_available_paths_to_active(mod: String, available_paths: Array, status: ModStatus.Value) -> Array:
  if status == ModStatus.REGULAR:
    return FileSystem.get_paths_with_swapped_directories(available_paths, Config.obse_available_mods_folder, _get_obse_plugin_folder())
  elif status == ModStatus.COPY_ON_ACTIVATION:
    return FileSystem.get_paths_with_swapped_directories(available_paths, CopyOnActivationMods.get_parent_dir_for_mod(mod_type, mod), _get_obse_plugin_folder())
  else:
    Global.fatal_error(["Unknown status '", status, "' encountered in OBSEModSelector::_convert_available_paths_to_active"])
    return []
