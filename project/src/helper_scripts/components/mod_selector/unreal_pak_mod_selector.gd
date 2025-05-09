class_name UnrealPakModSelector
extends BaseModSelector

func _custom_initialization() -> void:
  # Hide up/down arrows, they make no sense here
  up_button.visible = false
  down_button.visible = false

func _custom_add_file_dialog_setup() -> void:
  add_file_dialog.add_filter("*.pak", "Mod files")

func _activate_mod(mod: String) -> void:
  super._activate_mod(mod)
  active_mods_list.sort_items_by_text()

func _on_regular_mod_deletion(mod: String) -> void:
  var dir = _get_available_mod_dir(mod)
  if FileSystem.is_dir(dir):
    FileSystem.trash(dir)

var _unmanageable_mods_cache = []
func _read_active_mods_from_fs() -> Array:
  var base_dir = _get_active_mods_base_dir()

  var mods_with_mismatched_dir_names = FileSystem.directories_in(base_dir).filter(func(dir: String) -> bool:
    return not FileSystem.is_file(FileSystem.path([base_dir, dir, FileSystem.get_filename(dir) + "_P.pak"]))
  )

  var mods_outside_dirs = FileSystem.files_in(base_dir).filter(func(file: String) -> bool:
    return file.ends_with("_P.pak")
  ).map(func(file: String) -> String:
    return _get_mod_name_from_file(file)
  )

  _unmanageable_mods_cache = mods_with_mismatched_dir_names + mods_outside_dirs

  var manageable_mods = FileSystem.directories_in(_get_active_mods_base_dir()).filter(func(dir: String) -> bool:
    return dir not in _unmanageable_mods_cache
  )

  var mods = _unmanageable_mods_cache + manageable_mods
  mods.sort()
  return mods

func _read_other_available_mods_from_fs() -> Array:
  var dir = Config.unreal_pak_available_mods_folder
  if not FileSystem.is_dir(dir):
    return []
  return FileSystem.directories_in(dir)

func _perform_save_on_deactivated_regular_mod(mod: String) -> void:
  var from = _get_active_mod_dir(mod)
  var to = _get_available_mod_dir(mod)
  var action = Config.unreal_pak_regular_mod_deactivated_conflict_choice_for_mod_type

  if not FileSystem.is_dir(to):
    FileSystem.move(from, to)
  elif action == ModDeactivatedConflict.LEAVE:
    return # Don't do anything
  elif action == ModDeactivatedConflict.MOVE_BACK:
    FileSystem.trash(to)
    FileSystem.move(from, to)
  elif action == ModDeactivatedConflict.REMOVE:
    FileSystem.trash(from)
  else:
    Global.fatal_error(["Encountered unknown ModDeactivatedConflict '", action, "' in UnrealPakModSelector::_perform_save_on_deactivated_regular_mod"])

func _perform_save_on_deactivated_copy_on_activation_mod(mod: String) -> void:
  var mod_dir = _get_active_mod_dir(mod)
  var old_file = CopyOnActivationMods.get_path_for_mod(mod_type, mod)
  var action = Config.unreal_pak_copy_on_activation_mod_deactivated_conflict_choice_for_mod_type

  if FileSystem.is_file(old_file):
    FileSystem.trash(mod_dir)
  elif action == ModDeactivatedConflict.LEAVE:
    return # Don't do anything
  elif action == ModDeactivatedConflict.MOVE_BACK:
    _fs_move_mod_files_to_dir(mod, mod_dir, FileSystem.get_directory(old_file))
    FileSystem.remove(mod_dir)
  elif action == ModDeactivatedConflict.REMOVE:
    FileSystem.trash(mod_dir)
  else:
    Global.fatal_error(["Encountered unknown ModDeactivatedConflict '", action, "' in UnrealPakModSelector::_perform_save_on_deactivated_copy_on_activation_mod"])

func _perform_save_on_deactivated_not_found_mod(_mod: String) -> void:
  pass # There's nothing to do here

func _perform_save_on_activated_regular_mod(mod: String) -> void:
  var from = _get_available_mod_dir(mod)
  var to = _get_active_mod_dir(mod)
  var action = Config.get_mod_activated_conflict_choice_for_mod_type(mod_type)

  if not FileSystem.is_dir(to): # No conflict
    FileSystem.move(from, to)
  elif action == ModActivatedConflict.DEACTIVATE:
    return # Don't do anything
  elif action == ModActivatedConflict.REPLACE:
    FileSystem.trash(to)
    FileSystem.move(from, to)
  else:
    Global.fatal_error(["Encountered unknown ModActivatedConflict action '", action, "' in UnrealPakModSelector::_perform_save_on_activated_regular_mod"])

func _perform_save_on_activated_copy_on_activation_mod(mod: String) -> void:
  var from = FileSystem.get_directory(CopyOnActivationMods.get_path_for_mod(mod_type, mod))
  var to = _get_active_mod_dir(mod)
  var action = Config.get_mod_activated_conflict_choice_for_mod_type(mod_type)

  if not FileSystem.is_dir(to):
    _fs_copy_mod_files_to_dir(mod, from, to)
  elif action == ModActivatedConflict.DEACTIVATE:
    return # Don't do anything
  elif action == ModActivatedConflict.REPLACE:
    FileSystem.trash(to)
    _fs_copy_mod_files_to_dir(mod, from, to)
  else:
    Global.fatal_error(["Encountered unknown ModActivatedConflict '", action, "' in UnrealPakModSelector::_perform_save_on_activated_copy_on_activation_mod"])

func _perform_save_on_activated_not_found_mod(_mod: String) -> void:
  pass # There's nothing to do here - why would you even do this?

func _active_mod_is_not_found(mod: String) -> bool:
  return not FileSystem.is_file(_get_full_path_to_mod_file_in_dir(mod, _get_active_mod_dir(mod)))

func _other_available_mod_is_not_found(mod: String) -> bool:
  return not FileSystem.is_dir(_get_available_mod_dir(mod))

func _active_mod_is_unmanageable(mod: String) -> bool:
  return mod in _unmanageable_mods_cache

func _persist_mod_file_addition(mod: String, file: String, add_mode: AddMode.Value) -> void:
  if add_mode == AddMode.MOVE_ON_ADD:
    var to_path = _get_available_mod_dir(mod)
    _fs_move_mod_files_to_dir(mod, FileSystem.get_directory(file), to_path)
  elif add_mode == AddMode.COPY_ON_ACTIVATION:
    CopyOnActivationMods.add_for_mod_type(mod_type, mod, file)
  else:
    Global.fatal_error(["Encountered unknown AddMode '", add_mode, "' in UnrealPakModSelector::_persist_mod_file_addition"])

func _get_active_mods_base_dir() -> String:
  return FileSystem.path([Config.install_directory, "OblivionRemastered", "Content", "Paks", "~mods"])

func _get_active_mod_dir(mod: String) -> String:
  return FileSystem.path([_get_active_mods_base_dir(), mod])

func _get_available_mod_dir(mod: String) -> String:
  return FileSystem.path([Config.unreal_pak_available_mods_folder, mod])

func _get_mod_name_from_file(file: String) -> String:
  return FileSystem.get_filename(file, ["_P.pak"])

func _get_full_path_to_mod_file_in_dir(mod: String, dir: String) -> String:
  return FileSystem.path([dir, mod + "_P.pak"])

## Returns the full path of all the files related to the mod in the given directory
func _fs_read_mod_files_from_dir(mod: String, dir: String) -> Array:
  return FileSystem.files_in(dir).filter(func(file: String) -> bool:
    return file.begins_with(mod + "_P.")
  ).map(func(file: String) -> String:
    return FileSystem.path([dir, file])
  )

## Moves all the files related to the given mod in from_dir to to_dir
func _fs_move_mod_files_to_dir(mod: String, from_dir: String, to_dir: String) -> void:
  FileSystem.mkdir(to_dir) # Just in case

  var from_files = _fs_read_mod_files_from_dir(mod, from_dir)
  for from_file in from_files:
    var to_file = FileSystem.path([to_dir, FileSystem.get_filename(from_file)])
    FileSystem.move(from_file, to_file)

## Copies all the files related to the given mod in from_dir to to_dir
func _fs_copy_mod_files_to_dir(mod: String, from_dir: String, to_dir: String) -> void:
  FileSystem.mkdir(to_dir) # Just in case

  var from_files = _fs_read_mod_files_from_dir(mod, from_dir)
  for from_file in from_files:
    var to_file = FileSystem.path([to_dir, FileSystem.get_filename(from_file)])
    FileSystem.copy(from_file, to_file)
