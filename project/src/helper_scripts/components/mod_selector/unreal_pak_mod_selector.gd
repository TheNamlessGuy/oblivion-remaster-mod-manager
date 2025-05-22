class_name UnrealPakModSelector
extends BaseModSelector

func _custom_setup() -> void:
  # Hide up/down arrows, they make no sense here
  up_button.visible = false
  down_button.visible = false

  add_file_dialog.add_filter("*.pak", "Mod files")

func _activate_mod(mod: String) -> void:
  super._activate_mod(mod)
  active_mods_list.sort_items_by_text()

var _unmanageable_mods_cache := []
func _read_active_mods_from_fs() -> Array:
  var base_dir := _get_active_mods_base_dir()
  var magic_loader_is_installed := Game.magic_loader_is_installed()

  var mods_with_mismatched_dir_names := FileSystem.directories_in(base_dir).filter(func(dir: String) -> bool:
    if magic_loader_is_installed and dir == "MagicLoader": # We should ignore this folders entire existence if MagicLoader is installed
      return false

    return not FileSystem.is_file(FileSystem.path([base_dir, dir, FileSystem.get_filename(dir) + "_P.pak"]))
  )

  var mods_outside_dirs := FileSystem.files_in(base_dir).filter(func(file: String) -> bool:
    return file.ends_with("_P.pak")
  ).map(func(file: String) -> String:
    return _get_mod_name_from_file(file)
  )

  _unmanageable_mods_cache = mods_with_mismatched_dir_names + mods_outside_dirs

  var manageable_mods := FileSystem.directories_in(base_dir).filter(func(dir: String) -> bool:
    if magic_loader_is_installed and dir == "MagicLoader": # We should ignore this folders entire existence if MagicLoader is installed
      return false

    return dir not in _unmanageable_mods_cache
  )

  var mods := _unmanageable_mods_cache + manageable_mods
  mods.sort()
  return mods

func _read_other_available_mods_from_fs() -> Array:
  var dir := Config.unreal_pak_available_mods_folder
  if not FileSystem.is_dir(dir):
    return []

  return FileSystem.directories_in(dir).filter(func(d: String) -> bool:
    return not _active_mod_exists(d, false)
  )

func _active_mod_is_not_found(mod: String) -> bool:
  return not FileSystem.is_file(FileSystem.path([_get_active_mod_dir(mod), mod + "_P.pak"]))

func _other_available_mod_is_not_found(mod: String) -> bool:
  return not FileSystem.is_dir(_get_available_mod_dir(mod))

func _active_mod_is_unmanageable(mod: String) -> bool:
  return mod in _unmanageable_mods_cache

func _persist_mod_file_addition(mod: String, file: String, add_mode: AddMode.Value) -> void:
  if add_mode == AddMode.MOVE_ON_ADD:
    var to_path := _get_available_mod_dir(mod)
    _fs_move_mod_files_to_dir(mod, FileSystem.get_directory(file), to_path)
  elif add_mode == AddMode.COPY_ON_ACTIVATION:
    CopyOnActivationMods.add_for_mod_type(mod_type, mod, file)
  else:
    Global.fatal_error(["Encountered unknown AddMode '", add_mode, "' in UnrealPakModSelector::_persist_mod_file_addition"])

func _get_active_mods_base_dir() -> String:
  return FileSystem.path([Game.get_pak_dir(), "~mods"])

func _get_active_mod_dir(mod: String) -> String:
  return FileSystem.path([_get_active_mods_base_dir(), mod])

func _get_available_mod_dir(mod: String) -> String:
  return FileSystem.path([Config.unreal_pak_available_mods_folder, mod])

func _get_mod_name_from_file(file: String) -> String:
  return FileSystem.get_filename(file, ["_P.pak"])

## Returns the full path of all the files related to the mod in the given directory
func _fs_read_mod_files_from_dir(mod: String, dir: String) -> Array:
  return FileSystem.files_in(dir).filter(func(file: String) -> bool:
    return file.begins_with(mod + "_P.")
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
  return _fs_read_mod_files_from_dir(mod, _get_active_mod_dir(mod))

func _convert_active_paths_to_available(mod: String, active_paths: Array, status: ModStatus.Value) -> Array:
  if status == ModStatus.REGULAR:
    return FileSystem.get_paths_with_swapped_directories(active_paths, _get_active_mod_dir(mod), _get_available_mod_dir(mod))
  elif status == ModStatus.COPY_ON_ACTIVATION:
    return FileSystem.get_paths_with_swapped_directories(active_paths, _get_active_mod_dir(mod), CopyOnActivationMods.get_parent_dir_for_mod(mod_type, mod))
  else:
    Global.fatal_error(["Unknown status '", status, "' encountered in UnrealPakModSelector::_convert_active_paths_to_available"])
    return []

func _get_available_paths_for_mod(mod: String, status: ModStatus.Value) -> Array:
  if status == ModStatus.REGULAR:
    return _fs_read_mod_files_from_dir(mod, _get_available_mod_dir(mod))
  elif status == ModStatus.COPY_ON_ACTIVATION:
    return _fs_read_mod_files_from_dir(mod, CopyOnActivationMods.get_parent_dir_for_mod(mod_type, mod))
  else:
    Global.fatal_error(["Unknown status '", status, "' encountered in UnrealPakModSelector::_get_available_paths_for_mod"])
    return []

func _convert_available_paths_to_active(mod: String, available_paths: Array, status: ModStatus.Value) -> Array:
  if status == ModStatus.REGULAR:
    return FileSystem.get_paths_with_swapped_directories(available_paths, _get_available_mod_dir(mod), _get_active_mod_dir(mod))
  elif status == ModStatus.COPY_ON_ACTIVATION:
    return FileSystem.get_paths_with_swapped_directories(available_paths, CopyOnActivationMods.get_parent_dir_for_mod(mod_type, mod), _get_active_mod_dir(mod))
  else:
    Global.fatal_error(["Unknown status '", status, "' encountered in UnrealPakModSelector::_convert_available_paths_to_active"])
    return []
