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

func _custom_disabled_actions() -> void:
  _magic_button.tooltip_text = "This will be done automatically on save, but if you want to do it manually, click here"
  if Global.get_os() != Global.OperatingSystem.WINDOWS:
    _magic_button.tooltip_text += "\n\nThis operation is currently not supported on non-windows installations"
    _magic_button.disabled = true

func _activate_mod(mod: String) -> void:
  super._activate_mod(mod)
  active_mods_list.sort_items_by_text()

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

    var non_json_files_in_dir := files_in_dir.filter(func(file: String) -> bool: return not file.ends_with(".json"))
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

func _custom_post_save_actions() -> void:
  _do_magic()

func _active_mod_is_not_found(mod: String) -> bool:
  return not FileSystem.is_file(_get_active_path_for_mod(mod))

func _other_available_mod_is_not_found(mod: String) -> bool:
  return not FileSystem.is_file(_get_available_regular_path_for_mod(mod))

func _active_mod_is_unmanageable(mod: String) -> bool:
  return mod in _unmanageable_mods_cache

func _get_mod_name_from_file(file: String) -> String:
  return FileSystem.get_filename(file, [".json"])

func _get_filename_from_mod(mod: String) -> String:
  return mod + ".json"

func _get_active_path_for_mod(mod: String) -> String:
  return FileSystem.path([_get_magic_loader_mod_directory(), _get_filename_from_mod(mod)])

func _get_available_regular_path_for_mod(mod: String) -> String:
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

func _get_active_paths_for_mod(mod: String) -> Array:
  return [_get_active_path_for_mod(mod)]

func _convert_active_paths_to_available(mod: String, active_paths: Array, status: ModStatus.Value) -> Array:
  if status == ModStatus.REGULAR:
    return FileSystem.get_paths_with_swapped_directories(active_paths, _get_magic_loader_mod_directory(), Config.magic_loader_available_mods_folder)
  elif status == ModStatus.COPY_ON_ACTIVATION:
    return FileSystem.get_paths_with_swapped_directories(active_paths, _get_magic_loader_mod_directory(), CopyOnActivationMods.get_parent_dir_for_mod(mod_type, mod))
  else:
    Global.fatal_error(["Unknown status '", status, "' encountered in MagicLoaderModSelector::_convert_active_paths_to_available"])
    return []

func _get_available_paths_for_mod(mod: String, status: ModStatus.Value) -> Array:
  if status == ModStatus.REGULAR:
    return [_get_available_regular_path_for_mod(mod)]
  elif status == ModStatus.COPY_ON_ACTIVATION:
    return [CopyOnActivationMods.get_path_for_mod(mod_type, mod)]
  else:
    Global.fatal_error(["Unknown status '", status, "' encountered in MagicLoaderModSelector::_get_available_paths_for_mod"])
    return []

func _convert_available_paths_to_active(mod: String, available_paths: Array, status: ModStatus.Value) -> Array:
  if status == ModStatus.REGULAR:
    return FileSystem.get_paths_with_swapped_directories(available_paths, Config.magic_loader_available_mods_folder, _get_magic_loader_mod_directory())
  elif status == ModStatus.COPY_ON_ACTIVATION:
    return FileSystem.get_paths_with_swapped_directories(available_paths, CopyOnActivationMods.get_parent_dir_for_mod(mod_type, mod), _get_magic_loader_mod_directory())
  else:
    Global.fatal_error(["Unknown status '", status, "' encountered in MagicLoaderModSelector::_convert_available_paths_to_active"])
    return []
