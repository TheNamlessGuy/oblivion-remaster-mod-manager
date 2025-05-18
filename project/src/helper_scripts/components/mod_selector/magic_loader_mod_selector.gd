class_name MagicLoaderModSelector
extends BaseModSelector

func _custom_prerequisites_checks() -> void:
  if not Game.magic_loader_is_installed():
    alert_container.info(["Couldn't find MagicLoader installation. Please make sure it's properly installed, then come back and press Reload"])

var _fix_unmanageable_button: Button = null
var _magic_button: Button = null
func _custom_setup() -> void:
  up_button.visible = false
  down_button.visible = false

  add_file_dialog.add_filter("*.json", "Mod files")

  _fix_unmanageable_button = _add_custom_button("Fix unmanageable mods")
  _fix_unmanageable_button.tooltip_text = "NORMM will try to fix the listed unmanageable mods to the best of its abilities. Worst case, they'll keep being unmanageable.\nThis can't be done with unsaved changes."
  _fix_unmanageable_button.visible = false
  _fix_unmanageable_button.button_up.connect(_fix_unmanageable_mods)
  dirty_status_changed.connect(func(to: bool) -> void: _fix_unmanageable_button.disabled = to)

  _magic_button = _add_custom_button("Do magic")
  _magic_button.button_up.connect(_do_magic)
  if Global.get_os() != Global.OperatingSystem.WINDOWS:
    _magic_button.tooltip_text += "\n\nThis operation is currently not supported on non-windows installations"

func _custom_disabled_actions() -> void:
  _magic_button.tooltip_text = "This will be done automatically on save, but if you want to do it manually, click here"
  if Global.get_os() != Global.OperatingSystem.WINDOWS:
    _magic_button.tooltip_text += "\n\nThis operation is currently not supported on non-windows installations"
    _magic_button.disabled = true

func _activate_mod(mod: String) -> void:
  super._activate_mod(mod)
  active_mods_list.sort_items_by_text()

func _on_regular_mod_deletion(mod: String) -> void:
  var file := _get_available_path_for_mod(mod)
  if FileSystem.is_file(file):
    FileSystem.trash(file)

var _unmanageable_mods_cache := []
func _read_active_mods_from_fs() -> Array:

  var unmanageables := _read_unmanageable_mods_from_fs()
  _unmanageable_mods_cache = unmanageables[0] + unmanageables[1]

  _fix_unmanageable_button.visible = unmanageables[0].size() > 0

  var manageable_mods: Array[String] = []
  var base_dir := _get_magic_loader_mod_directory()
  var files := FileSystem.files_in(base_dir)
  for file in files:
    if not file.ends_with(".json"): continue
    var mod := _get_mod_name_from_file(file)
    if mod not in _unmanageable_mods_cache:
      manageable_mods.push_back(mod)

  var mods := _unmanageable_mods_cache + manageable_mods
  mods.sort()
  return mods

func _read_unmanageable_mods_from_fs() -> Array:
  var dirs_with_mods_in: Array[String] = []
  var other_dirs: Array[String] = []

  var base_dir := _get_magic_loader_mod_directory()
  var dirs := FileSystem.directories_in(base_dir)
  for dir in dirs:
    var full_path := FileSystem.path([base_dir, dir])
    var dirs_in_dir := FileSystem.directories_in(full_path)
    if dirs_in_dir.size() > 0:
      other_dirs.push_back(dir)
      continue

    var files_in_dir := FileSystem.files_in(full_path)
    if files_in_dir.size() == 0:
      other_dirs.push_back(dir)
      continue

    var non_json_files_in_dir := files_in_dir.filter(func(file: String) -> bool:return not file.ends_with(".json"))
    if non_json_files_in_dir.size() == 0:
      dirs_with_mods_in.push_back(dir)
    else:
      other_dirs.push_back(dir)

  return [dirs_with_mods_in, other_dirs]

func _read_other_available_mods_from_fs() -> Array:
  var dir := Config.magic_loader_available_mods_folder
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

# START: Save section

func _perform_save_on_deactivated_regular_mod(mod: String, diffs: Dictionary, remembered_choices: Dictionary) -> bool:
  var from := _get_active_path_for_mod(mod)
  var to := _get_available_path_for_mod(mod)

  var save_type := ModDiffType.DEACTIVATED_REGULAR
  var remembered_choice: ModDeactivatedConflict.Value = remembered_choices[save_type]
  var callback := _resolve_perform_save_on_deactivated_regular_mod_conflict.bind(from, to)

  if not FileSystem.exists(to): # No conflict
    FileSystem.move(from, to, true)
    return false
  elif remembered_choice != ModDeactivatedConflict.UNKNOWN:
    callback.call(remembered_choice)
    return false

  var prompt := ModDeactivatedConflictChoiceDialog.new()
  prompt.for_mod(ModStatus.REGULAR, mod, to)
  prompt.choice_made.connect(_on_save_conflict_prompt_response.bind(save_type, callback, diffs, remembered_choices))
  prompt.open(self)
  return true

func _resolve_perform_save_on_deactivated_regular_mod_conflict(action: ModDeactivatedConflict.Value, from: String, to: String) -> void:
  if action == ModDeactivatedConflict.LEAVE:
    pass # Don't do anything
  elif action == ModDeactivatedConflict.MOVE_BACK:
    FileSystem.trash(to)
    FileSystem.move(from, to, true)
  elif action == ModDeactivatedConflict.REMOVE:
    FileSystem.trash(from)
  else:
    Global.fatal_error(["Encountered unknown ModDeactivatedConflict '", action, "' in MagicLoaderModSelector::_resolve_perform_save_on_deactivated_regular_mod_conflict"])

func _perform_save_on_deactivated_copy_on_activation_mod(mod: String, diffs: Dictionary, remembered_choices: Dictionary) -> bool:
  var mod_file := _get_active_path_for_mod(mod)
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
    FileSystem.move(mod_file, old_file, true)
  elif action == ModDeactivatedConflict.REMOVE:
    FileSystem.trash(mod_file)
  else:
    Global.fatal_error(["Encountered unknown ModDeactivatedConflict '", action, "' in MagicLoaderModSelector::_resolve_perform_save_on_deactivated_copy_on_activation_mod_conflict"])

func _perform_save_on_deactivated_not_found_mod(_mod: String, _diffs: Dictionary, _remembered_choices: Dictionary) -> bool:
  return false # Noop

func _perform_save_on_activated_regular_mod(mod: String, diffs: Dictionary, remembered_choices: Dictionary) -> bool:
  var from := _get_available_path_for_mod(mod)
  var to := _get_active_path_for_mod(mod)

  var save_type := ModDiffType.ACTIVATED_REGULAR
  var remembered_choice: ModActivatedConflict.Value = remembered_choices[save_type]
  var callback := _resolve_perform_save_on_activated_regular_mod_conflict.bind(from, to)

  if not FileSystem.exists(to): # No conflict
    FileSystem.move(from, to, true)
    return false
  elif remembered_choice != ModActivatedConflict.UNKNOWN:
    callback.call(remembered_choice)
    return false

  var prompt := ModActivatedConflictChoiceDialog.new()
  prompt.for_mod(mod, to)
  prompt.choice_made.connect(_on_save_conflict_prompt_response.bind(save_type, callback, diffs, remembered_choices))
  prompt.open(self)
  return true

func _resolve_perform_save_on_activated_regular_mod_conflict(action: ModActivatedConflict.Value, from: String, to: String) -> void:
  if action == ModActivatedConflict.DEACTIVATE:
    pass # Don't do anything
  elif action == ModActivatedConflict.REPLACE:
    FileSystem.trash(to)
    FileSystem.move(from, to, true)
  else:
    Global.fatal_error(["Encountered unknown ModActivatedConflict action '", action, "' in MagicLoaderModSelector::_resolve_perform_save_on_activated_regular_mod_conflict"])

func _perform_save_on_activated_copy_on_activation_mod(mod: String, diffs: Dictionary, remembered_choices: Dictionary) -> bool:
  var from := CopyOnActivationMods.get_path_for_mod(mod_type, mod)
  var to := _get_active_path_for_mod(mod)

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
  prompt.for_mod(mod, to)
  prompt.choice_made.connect(_on_save_conflict_prompt_response.bind(save_type, callback, diffs, remembered_choices))
  prompt.open(self)
  return true

func _resolve_perform_save_on_activated_copy_on_activation_mod_conflict(action: ModActivatedConflict.Value, from: String, to: String) -> void:
  if action == ModActivatedConflict.DEACTIVATE:
    pass # Don't do anything
  elif action == ModActivatedConflict.REPLACE:
    FileSystem.trash(to)
    FileSystem.copy(from, to, true)
  else:
    Global.fatal_error(["Encountered unknown ModActivatedConflict '", action, "' in MagicLoaderModSelector::_resolve_perform_save_on_activated_copy_on_activation_mod_conflict"])

func _perform_save_on_activated_not_found_mod(_mod: String, _diffs: Dictionary, _remembered_choices: Dictionary) -> bool:
  return false # Noop

func _custom_post_save_actions() -> void:
  _do_magic()

# END: Save section

func _active_mod_is_not_found(mod: String) -> bool:
  return not FileSystem.is_file(_get_active_path_for_mod(mod))

func _other_available_mod_is_not_found(mod: String) -> bool:
  return not FileSystem.is_file(_get_available_path_for_mod(mod))

func _active_mod_is_unmanageable(mod: String) -> bool:
  return mod in _unmanageable_mods_cache

func _get_mod_name_from_file(file: String) -> String:
  return FileSystem.get_filename(file, [".json"])

func _get_filename_from_mod(mod: String) -> String:
  return mod + ".json"

func _get_active_path_for_mod(mod: String) -> String:
  return FileSystem.path([_get_magic_loader_mod_directory(), _get_filename_from_mod(mod)])

func _get_available_path_for_mod(mod: String) -> String:
  return FileSystem.path([Config.magic_loader_available_mods_folder, _get_filename_from_mod(mod)])

func _persist_mod_file_addition(mod: String, file: String, add_mode: AddMode.Value) -> void:
  if add_mode == AddMode.MOVE_ON_ADD:
    var to_path := FileSystem.path([Config.magic_loader_available_mods_folder, FileSystem.get_filename(file)])
    FileSystem.move(file, to_path)
  elif add_mode == AddMode.COPY_ON_ACTIVATION:
    CopyOnActivationMods.add_for_mod_type(mod_type, mod, file)
  else:
    Global.fatal_error(["Encountered unknown AddMode '", add_mode, "' in MagicLoaderModSelector::_persist_mod_file_addition"])

func _get_magic_loader_mod_directory() -> String:
  return FileSystem.path([Game.get_data_dir(), "MagicLoader"])

## Calls MagicLoader
func _do_magic() -> void:
  alert_container.clear()

  if Global.get_os() != Global.OperatingSystem.WINDOWS:
    alert_container.warning(["Can't run MagicLoader automatically, since NORMM isn't running on Windows. Please run it manually"])
    return

  var response := Global.run_program(Game.get_magic_loader_cli())
  if response.exit_code != 0:
    alert_container.error(["Failed to run MagicLoader. Error code: ", response.exit_code, ", error: ", response.stderr])

func _fix_unmanageable_mods() -> void:
  alert_container.clear()

  var base_dir := _get_magic_loader_mod_directory()
  var dirs_with_mods_in: Array = _read_unmanageable_mods_from_fs()[0]
  for dir in dirs_with_mods_in:
    var full_path := FileSystem.path([base_dir, dir])
    var files := FileSystem.files_in(full_path)
    for file in files:
      var from_path := FileSystem.path([full_path, file])
      var to_path := FileSystem.path([base_dir, file])

      if not FileSystem.exists(to_path):
        FileSystem.move(from_path, to_path)
      else:
        alert_container.warning(["Couldn't fix '", from_path.replace(base_dir + "/", ""), "', since there's already something at '", file, "'"])

    if FileSystem.files_in(full_path).size() == 0:
      FileSystem.trash(full_path)

  reload()
