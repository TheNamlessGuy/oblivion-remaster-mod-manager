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
  var ue4ss_activator := FileSystem.path([Game.get_bin_path(), "dwmapi.dll"])
  var ue4ss_folder := _get_ue4ss_mods_dir()
  if not FileSystem.is_file(ue4ss_activator):
    alert_container.info(["Couldn't find the file 'dwmapi.dll'. Please make sure UE4SS is installed correctly"])
  elif not FileSystem.is_dir(ue4ss_folder):
    alert_container.info(["Couldn't find the UE4SS mods folder. Please make sure UE4SS is installed correctly"])

func _custom_setup() -> void:
  add_file_dialog.add_filter("main.lua,main.dll", "Mod files")

func _attempted_added_mod_is_valid(file: String) -> bool:
  var result = _is_valid_mod_directory(_get_mod_dir_from_file(file))
  if result != null:
    alert_container.error(result)
    return false

  return true

var _unmanageable_mods_cache: Array = []
func _read_active_mods_from_fs() -> Array:
  var base_dir := _get_ue4ss_mods_dir()
  var dirs := FileSystem.directories_in(base_dir)

  var mods_activated_via_enabled_txt_file := dirs.filter(func(dir: String) -> bool:
    return dir not in _PREINSTALLED_MODS and FileSystem.is_file(FileSystem.path([base_dir, dir, "enabled.txt"]))
  )

  var mods_with_faulty_contents := dirs.filter(func(dir: String) -> bool:
    return dir not in _PREINSTALLED_MODS and _is_valid_mod_directory(FileSystem.path([base_dir, dir])) != null
  )

  _unmanageable_mods_cache = mods_activated_via_enabled_txt_file + mods_with_faulty_contents

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

func _custom_post_save_actions() -> void:
  # Write active_mod_list to mods.txt
  var mods := _ACTIVE_PREINSTALLED_MODS + _mod_list_to_array(active_mods_list)

  mods = mods.filter(func(mod: String) -> bool:
    return mod not in _unmanageable_mods_cache
  ).map(func(mod: String) -> String:
    return mod + " : 1"
  )

  FileSystem.write_lines(_get_ue4ss_mods_file(), mods)

func _other_available_mod_is_not_found(mod: String) -> bool:
  return not FileSystem.is_dir(_get_active_mod_dir(mod))

func _active_mod_is_unmanageable(mod: String) -> bool:
  return mod in _unmanageable_mods_cache

func _get_mod_dir_from_file(file: String) -> String:
  return FileSystem.get_directory(FileSystem.get_directory(file))

func _get_mod_name_from_file(file: String) -> String:
  return FileSystem.get_filename(_get_mod_dir_from_file(file))

func _persist_mod_file_addition(mod: String, file: String, add_mode: AddMode.Value) -> void:
  if add_mode == AddMode.MOVE_ON_ADD:
    _persist_mod_dir_move(_get_mod_dir_from_file(file), _get_active_mod_dir(mod))
  elif add_mode == AddMode.COPY_ON_ACTIVATION:
    CopyOnActivationMods.add_for_mod_type(mod_type, mod, file)
  else:
    Global.fatal_error(["Encountered unknown AddMode '", add_mode, "' in UE4SSModSelector::_persist_mod_file_addition"])

func _get_ue4ss_mods_dir() -> String:
  return FileSystem.path([Game.get_bin_path(), "ue4ss", "Mods"])

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

func _persist_mod_dir_move(mod_dir: String, to_dir: String):
  FileSystem.move(mod_dir, to_dir, true)

  var enabled_txt := FileSystem.path([to_dir, "enabled.txt"])
  if FileSystem.is_file(enabled_txt):
    FileSystem.trash(enabled_txt)

func _persist_mod_dir_copy(mod_dir: String, to_dir: String):
  FileSystem.copy(mod_dir, to_dir, true)

  var enabled_txt := FileSystem.path([to_dir, "enabled.txt"])
  if FileSystem.is_file(enabled_txt):
    FileSystem.trash(enabled_txt)

func _get_active_paths_for_mod(mod: String) -> Array:
  var mod_dir := _get_active_mod_dir(mod)
  var paths = FileSystem.directory_contents(mod_dir, true).map(func(content: String) -> String:
    return FileSystem.path([mod_dir, content])
  )

  if FileSystem.is_dir(mod_dir):
    paths.push_back(mod_dir)

  return paths

func _convert_active_paths_to_available(mod: String, active_paths: Array, status: ModStatus.Value) -> Array:
  if status == ModStatus.REGULAR:
    return active_paths # No difference between active and available
  elif status == ModStatus.COPY_ON_ACTIVATION:
    var active_dir := _get_active_mod_dir(mod)
    var available_dir := _get_mod_dir_from_file(CopyOnActivationMods.get_path_for_mod(mod_type, mod))
    return FileSystem.get_paths_with_swapped_directories(active_paths, active_dir, available_dir)
  else:
    Global.fatal_error(["Unknown status '", status, "' encountered in UE4SSModSelector::_convert_active_paths_to_available"])
    return []

func _get_available_paths_for_mod(mod: String, status: ModStatus.Value) -> Array:
  if status == ModStatus.REGULAR:
    return _get_active_paths_for_mod(mod) # No difference between active and available
  elif status == ModStatus.COPY_ON_ACTIVATION:
    var available_dir := _get_mod_dir_from_file(CopyOnActivationMods.get_path_for_mod(mod_type, mod))
    return FileSystem.directory_contents(available_dir, true).map(func(content: String) -> String:
      return FileSystem.path([available_dir, content])
    )
  else:
    Global.fatal_error(["Unknown status '", status, "' encountered in UE4SSModSelector::_get_available_paths_for_mod"])
    return []

func _convert_available_paths_to_active(mod: String, available_paths: Array, status: ModStatus.Value) -> Array:
  if status == ModStatus.REGULAR:
    return available_paths # No difference between active and available
  elif status == ModStatus.COPY_ON_ACTIVATION:
    var active_dir := _get_active_mod_dir(mod)
    var available_dir := _get_mod_dir_from_file(CopyOnActivationMods.get_path_for_mod(mod_type, mod))
    return FileSystem.get_paths_with_swapped_directories(available_paths, available_dir, active_dir)
  else:
    Global.fatal_error(["Unknown status '", status, "' encountered in UE4SSModSelector::_convert_available_paths_to_active"])
    return []

## Returns null if it is valid, or an array of values explaining what's wrong with the directory if it isn't
func _is_valid_mod_directory(mod_dir: String) -> Variant:
  var script_folder_name := ""
  var dll_folder_name := ""

  var dirs := FileSystem.directories_in(mod_dir)
  for dir in dirs:
    if dir.to_lower() == "scripts": script_folder_name = dir
    elif dir.to_lower() == "dlls": dll_folder_name = dir

  var main_script_exists := false if script_folder_name.length() == 0 else FileSystem.exists(FileSystem.path([mod_dir, script_folder_name, "main.lua"]))
  var main_dll_exists := false if dll_folder_name.length() == 0 else FileSystem.exists(FileSystem.path([mod_dir, dll_folder_name, "main.dll"]))

  if not main_script_exists and not main_dll_exists:
    if script_folder_name.length() == 0: script_folder_name = 'scripts'
    if dll_folder_name.length() == 0: dll_folder_name = 'dlls'
    return ["The directory '", mod_dir, "' is invalid, since it doesn't contain '", script_folder_name, "/main.lua' nor '", dll_folder_name, "/main.dll'"]

  return null
