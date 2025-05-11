class_name OBSEModSelector
extends BaseModSelector

func _custom_initialization() -> void:
  # Hide up/down arrows, they make no sense here
  up_button.visible = false
  down_button.visible = false

func _custom_add_file_dialog_setup() -> void:
  add_file_dialog.add_filter("*.dll", "Mod files")

func _custom_prerequisites_checks() -> void:
  var obse_loader_path := FileSystem.path([Game.get_bin_path(), "obse64_loader.exe"])
  if not FileSystem.is_file(obse_loader_path):
    alert_container.info(["Couldn't find 'obse64_loader.exe'. Please make sure OBSE is installed correctly"])

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

  return _get_mods_in_dir(dir).filter(func(mod: String) -> bool:
    return not _active_mod_exists(mod, false)
  )

# START: Save section

func _perform_save_on_deactivated_regular_mod(mod: String, diffs: Dictionary, remembered_choices: Dictionary) -> bool:
  var active_mods_folder := _get_obse_plugin_folder()
  var available_mods_folder := Config.obse_available_mods_folder
  var to_file := _get_full_path_to_mod_file_in_dir(mod, available_mods_folder)

  var save_type := ModDiffType.DEACTIVATED_REGULAR
  var remembered_choice: ModDeactivatedConflict.Value = remembered_choices[save_type]
  var callback := _resolve_perform_save_on_deactivated_regular_mod_conflict.bind(mod, active_mods_folder, available_mods_folder)

  if not FileSystem.exists(to_file): # No conflict
    _fs_move_mod_files_to_dir(mod, active_mods_folder, available_mods_folder)
    return false
  elif remembered_choice != ModDeactivatedConflict.UNKNOWN:
    callback.call(remembered_choice)
    return false

  var prompt := ModDeactivatedConflictChoiceDialog.new()
  prompt.for_mod(ModStatus.REGULAR, mod, to_file)
  prompt.choice_made.connect(_on_save_conflict_prompt_response.bind(save_type, callback, diffs, remembered_choices))
  prompt.open(self)
  return true

func _resolve_perform_save_on_deactivated_regular_mod_conflict(action: ModDeactivatedConflict.Value, mod: String, active_mods_folder: String, available_mods_folder: String) -> void:
  if action == ModDeactivatedConflict.LEAVE:
    pass # Don't do anything
  elif action == ModDeactivatedConflict.MOVE_BACK:
    _fs_trash_mod_files_in_dir(mod, available_mods_folder)
    _fs_move_mod_files_to_dir(mod, active_mods_folder, available_mods_folder)
  elif action == ModDeactivatedConflict.REMOVE:
    _fs_trash_mod_files_in_dir(mod, active_mods_folder)
  else:
    Global.fatal_error(["Encountered unknown ModDeactivatedConflict action '", action, "' in OBSEModSelector::_resolve_perform_save_on_deactivated_regular_mod_conflict"])

func _perform_save_on_deactivated_copy_on_activation_mod(mod: String, diffs: Dictionary, remembered_choices: Dictionary) -> bool:
  var active_mods_folder := _get_obse_plugin_folder()
  var old_file := CopyOnActivationMods.get_path_for_mod(mod_type, mod)

  var save_type := ModDiffType.DEACTIVATED_COPY_ON_ACTIVATION
  var remembered_choice: ModDeactivatedConflict.Value = remembered_choices[save_type]
  var callback := _resolve_perform_save_on_deactivated_copy_on_activation_mod_conflict.bind(mod, active_mods_folder, old_file)

  if FileSystem.exists(old_file): # No conflict
    _fs_trash_mod_files_in_dir(mod, active_mods_folder)
    return false
  elif remembered_choice != ModDeactivatedConflict.UNKNOWN:
    callback.call(remembered_choice)
    return false

  var prompt := ModDeactivatedConflictChoiceDialog.new()
  prompt.for_mod(ModStatus.COPY_ON_ACTIVATION, mod, old_file)
  prompt.choice_made.connect(_on_save_conflict_prompt_response.bind(save_type, callback, diffs, remembered_choices))
  prompt.open(self)
  return true

func _resolve_perform_save_on_deactivated_copy_on_activation_mod_conflict(action: ModDeactivatedConflict.Value, mod: String, active_mods_folder: String, old_file: String) -> void:
  if action == ModDeactivatedConflict.LEAVE:
    pass # Don't do anything
  elif action == ModDeactivatedConflict.MOVE_BACK:
    _fs_move_mod_files_to_dir(mod, active_mods_folder, FileSystem.get_directory(old_file))
  elif action == ModDeactivatedConflict.REMOVE:
    _fs_trash_mod_files_in_dir(mod, active_mods_folder)
  else:
    Global.fatal_error(["Encountered unknown ModDeactivatedConflict action '", action, "' in OBSEModSelector::_resolve_perform_save_on_deactivated_copy_on_activation_mod_conflict"])

func _perform_save_on_deactivated_not_found_mod(_mod: String, _diffs: Dictionary, _remembered_choices: Dictionary) -> bool:
  return false # There's nothing to do here

func _perform_save_on_activated_regular_mod(mod: String, diffs: Dictionary, remembered_choices: Dictionary) -> bool:
  var active_mods_folder := _get_obse_plugin_folder()
  var available_mods_folder := Config.obse_available_mods_folder
  var to_file := _get_full_path_to_mod_file_in_dir(mod, active_mods_folder)

  var save_type := ModDiffType.ACTIVATED_REGULAR
  var remembered_choice: ModActivatedConflict.Value = remembered_choices[save_type]
  var callback := _resolve_perform_save_on_activated_regular_mod_conflict.bind(mod, active_mods_folder, available_mods_folder)

  if not FileSystem.exists(to_file): # No conflict
    _fs_move_mod_files_to_dir(mod, available_mods_folder, active_mods_folder)
    return false
  elif remembered_choice != ModActivatedConflict.UNKNOWN:
    callback.call(remembered_choice)
    return false

  var prompt := ModActivatedConflictChoiceDialog.new()
  prompt.for_mod(mod, to_file)
  prompt.choice_made.connect(_on_save_conflict_prompt_response.bind(save_type, callback, diffs, remembered_choices))
  prompt.open(self)
  return true

func _resolve_perform_save_on_activated_regular_mod_conflict(action: ModActivatedConflict.Value, mod: String, active_mods_folder: String, available_mods_folder: String) -> void:
  if action == ModActivatedConflict.DEACTIVATE:
    pass # Don't do anything
  elif action == ModActivatedConflict.REPLACE:
    _fs_trash_mod_files_in_dir(mod, active_mods_folder)
    _fs_move_mod_files_to_dir(mod, available_mods_folder, active_mods_folder)
  else:
    Global.fatal_error(["Encountered unknown ModActivatedConflict action '", action, "' in OBSEModSelector::_resolve_perform_save_on_activated_regular_mod_conflict"])

func _perform_save_on_activated_copy_on_activation_mod(mod: String, diffs: Dictionary, remembered_choices: Dictionary) -> bool:
  var active_mods_folder := _get_obse_plugin_folder()
  var mod_home_folder := FileSystem.get_directory(CopyOnActivationMods.get_path_for_mod(mod_type, mod))
  var to_file := _get_full_path_to_mod_file_in_dir(mod, active_mods_folder)

  var save_type := ModDiffType.ACTIVATED_COPY_ON_ACTIVATION
  var remembered_choice: ModActivatedConflict.Value = remembered_choices[save_type]
  var callback := _resolve_perform_save_on_activated_copy_on_activation_mod_conflict.bind(mod, active_mods_folder, mod_home_folder)

  if not FileSystem.exists(to_file): # No conflict
    _fs_copy_mod_files_to_dir(mod, mod_home_folder, active_mods_folder)
    return false
  elif remembered_choice != ModActivatedConflict.UNKNOWN:
    callback.call(remembered_choice)
    return false

  var prompt := ModActivatedConflictChoiceDialog.new()
  prompt.for_mod(mod, to_file)
  prompt.choice_made.connect(_on_save_conflict_prompt_response.bind(save_type, callback, diffs, remembered_choices))
  prompt.open(self)
  return true

func _resolve_perform_save_on_activated_copy_on_activation_mod_conflict(action: ModActivatedConflict.Value, mod: String, active_mods_folder: String, mod_home_folder: String) -> void:
  if action == ModActivatedConflict.DEACTIVATE:
    pass # Don't do anything
  elif action == ModActivatedConflict.REPLACE:
    _fs_trash_mod_files_in_dir(mod, active_mods_folder)
    _fs_copy_mod_files_to_dir(mod, mod_home_folder, active_mods_folder)
  else:
    Global.fatal_error(["Encountered unknown ModActivatedConflict action '", action, "' in OBSEModSelector::_resolve_perform_save_on_activated_copy_on_activation_mod_conflict"])

func _perform_save_on_activated_not_found_mod(_mod: String, _diffs: Dictionary, _remembered_choices: Dictionary) -> bool:
  return false # There's nothing to do here - why would you even do this?

# END: Save section

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

## Copies all the files related to the given mod in from_dir to to_dir
func _fs_copy_mod_files_to_dir(mod: String, from_dir: String, to_dir: String) -> void:
  var from_files := _fs_read_mod_files_from_dir(mod, from_dir)
  for from_file in from_files:
    var to_file := FileSystem.path([to_dir, FileSystem.get_filename(from_file)])
    FileSystem.copy(from_file, to_file, true)

## Trashes all the files related to the given mod in the given directory
func _fs_trash_mod_files_in_dir(mod: String, dir: String) -> void:
  var files := _fs_read_mod_files_from_dir(mod, dir)
  for file in files:
    FileSystem.trash(file)
