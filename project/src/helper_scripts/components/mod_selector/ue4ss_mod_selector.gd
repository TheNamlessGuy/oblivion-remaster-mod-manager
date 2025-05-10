class_name UE4SSModSelector
extends BaseModSelector

const _ACTIVE_PREINSTALLED_MODS := [
  "BPML_GenericFunctions",
  "BPModLoaderMod",
]

const _INACTIVE_PREINSTALLED_MODS := [
  "shared",
]

const _PREINSTALLED_MODS := _ACTIVE_PREINSTALLED_MODS + _INACTIVE_PREINSTALLED_MODS

func _custom_prerequisites_checks() -> void:
  # Is UE4SS installed?
  var ue4ss_activator := FileSystem.path([Config.install_directory, "OblivionRemastered", "Binaries", "Win64", "dwmapi.dll"])
  var ue4ss_folder := _get_ue4ss_mods_dir()
  if not FileSystem.is_file(ue4ss_activator):
    alert_container.info(["Couldn't find the file 'dwmapi.dll'. Please make sure UE4SS is installed correctly"])
  elif not FileSystem.is_dir(ue4ss_folder):
    alert_container.info(["Couldn't find the UE4SS mods folder. Please make sure UE4SS is installed correctly"])

func _custom_add_file_dialog_setup() -> void:
  add_file_dialog.title = "Select the mod to add"
  add_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
  add_file_dialog.dir_selected.connect(_on_add_selected_dir)

func _on_regular_mod_deletion(mod: String) -> void:
  var dir := _get_active_mod_dir(mod)
  if FileSystem.is_dir(dir):
    FileSystem.trash(dir)

var _unmanageable_mods_cache: Array = []
func _read_active_mods_from_fs() -> Array:
  var base_dir := _get_ue4ss_mods_dir()

  var mods_activated_via_enabled_txt_file := FileSystem.directories_in(base_dir).filter(func(dir: String) -> bool:
    return FileSystem.is_file(FileSystem.path([base_dir, dir, "enabled.txt"]))
  )

  _unmanageable_mods_cache = mods_activated_via_enabled_txt_file

  var manageable_mods := _get_mods_specified_in_ue4ss_mods_file().filter(func(mod: Array) -> bool:
    return mod[_MOD_ACTIVATED] and mod[_MOD_NAME] not in _unmanageable_mods_cache and mod[_MOD_NAME] not in _PREINSTALLED_MODS
  ).map(func(mod: Array) -> String:
    return mod[_MOD_NAME]
  )

  return _unmanageable_mods_cache + manageable_mods

func _read_other_available_mods_from_fs() -> Array:
  return FileSystem.directories_in(_get_ue4ss_mods_dir()).filter(func(dir: String) -> bool:
    if dir in _PREINSTALLED_MODS:
      return false
    elif dir in _unmanageable_mods_cache:
      return false
    elif _active_mod_exists(dir, false):
      return false

    return true
  )

func _perform_save_on_deactivated_regular_mod(_mod: String) -> void:
  pass # Noop - The files should remain where they are, and _custom_post_save_actions will take care of marking it as not active

func _perform_save_on_deactivated_copy_on_activation_mod(mod: String) -> void:
  var mod_dir := _get_active_mod_dir(mod)
  var old_dir := CopyOnActivationMods.get_path_for_mod(mod_type, mod)
  var action := Config.get_mod_deactivated_conflict_choice_for_mod_type(mod_type)

  if FileSystem.is_dir(old_dir):
    FileSystem.trash(mod_dir)
  elif action == ModDeactivatedConflict.LEAVE:
    return # Don't do anything
  elif action == ModDeactivatedConflict.MOVE_BACK:
    _persist_mod_dir_move(mod_dir, old_dir)
  elif action == ModDeactivatedConflict.REMOVE:
    FileSystem.trash(mod_dir)
  else:
    Global.fatal_error(["Encountered unknown ModDeactivatedConflict '", action, "' in UE4SSModSelector::_perform_save_on_deactivated_copy_on_activation_mod"])

func _perform_save_on_deactivated_not_found_mod(_mod: String) -> void:
  pass # Noop

func _perform_save_on_activated_regular_mod(_mod: String) -> void:
  pass # Noop - the mod dir should already be in the correct folder, and _custom_post_save_actions will mark it as active

func _perform_save_on_activated_copy_on_activation_mod(mod: String) -> void:
  var from_dir := CopyOnActivationMods.get_path_for_mod(mod_type, mod)
  var to_dir := _get_active_mod_dir(mod)
  var action := Config.get_mod_activated_conflict_choice_for_mod_type(mod_type)

  if not FileSystem.is_dir(to_dir):
    _persist_mod_dir_copy(from_dir, to_dir)
  elif action == ModActivatedConflict.DEACTIVATE:
    return # Don't do anything
  elif action == ModActivatedConflict.REPLACE:
    FileSystem.trash(to_dir)
    _persist_mod_dir_copy(from_dir, to_dir)
  else:
    Global.fatal_error(["Encountered unknown ModActivatedConflict '", action, "' in UE4SSModSelector::_perform_save_on_activated_copy_on_activation_mod"])

func _perform_save_on_activated_not_found_mod(_mod: String) -> void:
  pass # Noop

func _custom_post_save_actions() -> void:
  # Write active_mod_list to mods.txt
  var mods := _ACTIVE_PREINSTALLED_MODS + _mod_list_to_array(active_mods_list)

  mods = mods.filter(func(mod: String) -> bool:
    return mod not in _unmanageable_mods_cache
  ).map(func(mod: String) -> String:
    return mod + " : 1"
  )

  FileSystem.write_lines(_get_ue4ss_mods_file(), mods)

func _active_mod_is_not_found(mod: String) -> bool:
  return not FileSystem.is_dir(_get_active_mod_dir(mod))

func _other_available_mod_is_not_found(mod: String) -> bool:
  return not FileSystem.is_dir(_get_active_mod_dir(mod))

func _active_mod_is_unmanageable(mod: String) -> bool:
  return mod in _unmanageable_mods_cache

func _get_mod_name_from_file(file: String) -> String:
  return FileSystem.get_filename(file)

func _persist_mod_file_addition(mod: String, dir: String, add_mode: AddMode.Value) -> void:
  if add_mode == AddMode.MOVE_ON_ADD:
    _persist_mod_dir_move(dir, _get_active_mod_dir(mod))
  elif add_mode == AddMode.COPY_ON_ACTIVATION:
    CopyOnActivationMods.add_for_mod_type(mod_type, mod, dir)
  else:
    Global.fatal_error(["Encountered unknown AddMode '", add_mode, "' in UE4SSModSelector::_persist_mod_file_addition"])

func _get_ue4ss_mods_dir() -> String:
  return FileSystem.path([Config.install_directory, "OblivionRemastered", "Binaries", "Win64", "ue4ss", "Mods"])

func _get_ue4ss_mods_file() -> String:
  return FileSystem.path([_get_ue4ss_mods_dir(), "mods.txt"])

func _get_active_mod_dir(mod: String) -> String:
  return FileSystem.path([_get_ue4ss_mods_dir(), mod])

const _MOD_NAME := 0
const _MOD_ACTIVATED := 1
func _get_mods_specified_in_ue4ss_mods_file() -> Array:
  var retval := []

  var lines := FileSystem.read_lines(_get_ue4ss_mods_file())
  for line in lines:
    if " : " not in line: continue

    var split := Array(line.split(" : "))
    split[_MOD_ACTIVATED] = split[_MOD_ACTIVATED] == "1"
    retval.push_back(split)

  return retval

## Called when the user selects a directory to add
func _on_add_selected_dir(dir: String) -> void:
  _on_add_selected_files(PackedStringArray([dir]))

func _persist_mod_dir_move(mod_dir: String, to_dir: String):
  FileSystem.move(mod_dir, to_dir)

  var enabled_txt := FileSystem.path([to_dir, "enabled.txt"])
  if FileSystem.is_file(enabled_txt):
    FileSystem.trash(enabled_txt)

func _persist_mod_dir_copy(mod_dir: String, to_dir: String):
  FileSystem.copy(mod_dir, to_dir)

  var enabled_txt := FileSystem.path([to_dir, "enabled.txt"])
  if FileSystem.is_file(enabled_txt):
    FileSystem.trash(enabled_txt)
