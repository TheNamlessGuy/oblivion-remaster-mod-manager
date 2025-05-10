class_name OBSEModSelector
extends BaseModSelector

func _custom_initialization() -> void:
  # Hide up/down arrows, they make no sense here
  up_button.visible = false
  down_button.visible = false

func _custom_add_file_dialog_setup() -> void:
  add_file_dialog.add_filter("*.dll", "Mod files")

func _custom_prerequisites_checks() -> void:
  var obse_loader_path := FileSystem.path([Config.install_directory, "OblivionRemastered", "Binaries", "Win64", "obse64_loader.exe"])
  if not FileSystem.is_file(obse_loader_path):
    alert_container.info(["Could not find 'obse64_loader.exe'. Please make sure OBSE is installed correctly"])

func _activate_mod(mod: String) -> void:
  super._activate_mod(mod)
  active_mods_list.sort_items_by_text()

func _on_regular_mod_deletion(mod: String) -> void:
  var mod_files := _fs_read_mod_files_from_dir(mod, Config.obse_available_mods_folder)
  for mod_file in mod_files:
    FileSystem.trash(mod_file)

func _read_active_mods_from_fs() -> Array:
  return _get_mods_in_dir(_get_obse_plugin_folder())

func _read_other_available_mods_from_fs() -> Array:
  var dir := Config.obse_available_mods_folder
  if not FileSystem.is_dir(dir):
    return []
  return _get_mods_in_dir(dir)

func _perform_save_on_deactivated_regular_mod(mod: String) -> void:
  var active_mods_folder := _get_obse_plugin_folder()
  var available_mods_folder := Config.obse_available_mods_folder

  var to_file := _get_full_path_to_mod_file_in_dir(mod, available_mods_folder)
  var action := Config.obse_regular_mod_deactivated_conflict_choice_for_mod_type

  if not FileSystem.is_file(to_file):
    _fs_move_mod_files_to_dir(mod, active_mods_folder, available_mods_folder)
  elif action == ModDeactivatedConflict.LEAVE:
    return # Don't do anything
  elif action == ModDeactivatedConflict.MOVE_BACK:
    _fs_trash_mod_files_in_dir(mod, available_mods_folder)
    _fs_move_mod_files_to_dir(mod, active_mods_folder, available_mods_folder)
  elif action == ModDeactivatedConflict.REMOVE:
    _fs_trash_mod_files_in_dir(mod, active_mods_folder)
  else:
    Global.fatal_error(["Encountered unknown ModDeactivatedConflict action '", action, "' in OBSEModSelector::_perform_save_on_deactivated_regular_mod"])

func _perform_save_on_deactivated_copy_on_activation_mod(mod: String) -> void:
  var active_mods_folder := _get_obse_plugin_folder()

  var old_file := CopyOnActivationMods.get_path_for_mod(mod_type, mod)
  var action := Config.obse_copy_on_activation_mod_deactivated_conflict_choice_for_mod_type

  if FileSystem.is_file(old_file):
    _fs_trash_mod_files_in_dir(mod, active_mods_folder)
  elif action == ModDeactivatedConflict.LEAVE:
    return # Don't do anything
  elif action == ModDeactivatedConflict.MOVE_BACK:
    _fs_move_mod_files_to_dir(mod, active_mods_folder, FileSystem.get_directory(old_file))
  elif action == ModDeactivatedConflict.REMOVE:
    _fs_trash_mod_files_in_dir(mod, active_mods_folder)
  else:
    Global.fatal_error(["Encountered unknown ModDeactivatedConflict action '", action, "' in OBSEModSelector::_perform_save_on_deactivated_copy_on_activation_mod"])

func _perform_save_on_deactivated_not_found_mod(_mod: String) -> void:
  pass # There's nothing to do here

func _perform_save_on_activated_regular_mod(mod: String) -> void:
  var active_mods_folder := _get_obse_plugin_folder()
  var available_mods_folder := Config.obse_available_mods_folder

  var to_file := _get_full_path_to_mod_file_in_dir(mod, active_mods_folder)
  var action := Config.get_mod_activated_conflict_choice_for_mod_type(mod_type)

  if not FileSystem.is_file(to_file):
    _fs_move_mod_files_to_dir(mod, available_mods_folder, active_mods_folder)
  elif action == ModActivatedConflict.DEACTIVATE:
    return # Don't do anything
  elif action == ModActivatedConflict.REPLACE:
    _fs_trash_mod_files_in_dir(mod, active_mods_folder)
    _fs_move_mod_files_to_dir(mod, available_mods_folder, active_mods_folder)
  else:
    Global.fatal_error(["Encountered unknown ModActivatedConflict action '", action, "' in OBSEModSelector::_perform_save_on_activated_regular_mod"])

func _perform_save_on_activated_copy_on_activation_mod(mod: String) -> void:
  var active_mods_folder := _get_obse_plugin_folder()
  var mod_home_folder := FileSystem.get_directory(CopyOnActivationMods.get_path_for_mod(mod_type, mod))

  var to_file := _get_full_path_to_mod_file_in_dir(mod, active_mods_folder)
  var action := Config.get_mod_activated_conflict_choice_for_mod_type(mod_type)

  if not FileSystem.is_file(to_file):
    _fs_copy_mod_files_to_dir(mod, mod_home_folder, active_mods_folder)
  elif action == ModActivatedConflict.DEACTIVATE:
    return # Don't do anything
  elif action == ModActivatedConflict.REPLACE:
    _fs_trash_mod_files_in_dir(mod, active_mods_folder)
    _fs_copy_mod_files_to_dir(mod, mod_home_folder, active_mods_folder)
  else:
    Global.fatal_error(["Encountered unknown ModActivatedConflict action '", action, "' in OBSEModSelector::_perform_save_on_activated_copy_on_activation_mod"])

func _perform_save_on_activated_not_found_mod(_mod: String) -> void:
  pass # There's nothing to do here - why would you even do this?

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
  return FileSystem.path([Config.install_directory, "OblivionRemastered", "Binaries", "Win64", "OBSE", "Plugins"])

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
  FileSystem.mkdir(to_dir) # Just in case

  var from_files := _fs_read_mod_files_from_dir(mod, from_dir)
  for from_file in from_files:
    var to_file := FileSystem.path([to_dir, FileSystem.get_filename(from_file)])
    FileSystem.move(from_file, to_file)

## Copies all the files related to the given mod in from_dir to to_dir
func _fs_copy_mod_files_to_dir(mod: String, from_dir: String, to_dir: String) -> void:
  FileSystem.mkdir(to_dir) # Just in case

  var from_files := _fs_read_mod_files_from_dir(mod, from_dir)
  for from_file in from_files:
    var to_file := FileSystem.path([to_dir, FileSystem.get_filename(from_file)])
    FileSystem.copy(from_file, to_file)

## Trashes all the files related to the given mod in the given directory
func _fs_trash_mod_files_in_dir(mod: String, dir: String) -> void:
  var files := _fs_read_mod_files_from_dir(mod, dir)
  for file in files:
    FileSystem.trash(file)
