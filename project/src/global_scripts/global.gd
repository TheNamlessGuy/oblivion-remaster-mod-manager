extends Node

func _ready() -> void:
  get_viewport().get_window().min_size = Vector2i(640, 480) # TODO: This seemingly doesn't do anything

func exit(exit_code) -> void:
  var tree = get_tree()
  tree.root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
  tree.quit(exit_code)

func fatal_error(msg: Array) -> void:
  OS.alert(array_to_string(msg), "Internal fatal error")
  Log.error(msg, get_stack())
  exit(1)

func array_to_string(array: Array) -> String:
  var retval = ""
  for item in array:
    retval += str(item)
  return retval

func install_directory_is_valid(dir = null) -> bool:
  if dir == null: dir = Config.install_directory

  if not FileSystem.is_dir(dir):
    return false

  var steam_executable = FileSystem.path([dir, "OblivionRemastered.exe"])
  var gamepass_executable = FileSystem.path([dir, "gamelaunchhelper.exe"])
  if not FileSystem.is_file(steam_executable) and not FileSystem.is_file(gamepass_executable):
    return false

  return true

func get_project_name() -> String:
  return ProjectSettings.get_setting("application/config/name")

func get_executable_name() -> String:
  if OS.is_debug_build():
    return "namless-oblivion-remaster-mod-manager"
  return FileSystem.get_filename(OS.get_executable_path(), [".exe"])

func get_executable_directory() -> String:
  if OS.is_debug_build():
    return ProjectSettings.globalize_path("res://")
  return FileSystem.get_directory(OS.get_executable_path())

func get_manager_folder() -> String: return FileSystem.path([get_executable_directory(), get_executable_name()])
func get_manager_subpath(file: String) -> String: return FileSystem.path([get_manager_folder(), file])

func arrays_diff(arr1: Array, arr2: Array) -> bool:
  if arr1.size() != arr2.size():
    return true

  for i in range(arr1.size()):
    if arr1[i] != arr2[i]:
      return true

  return false

func diff_arrays(arr1: Array, arr2: Array) -> Array:
  var retval = []

  for entry in arr1:
    if entry not in arr2:
      retval.push_back(entry)

  return retval

func clear_unchanged_dict_keys(dict: Dictionary, default: Dictionary, ignore_subdict_changes: bool = false) -> Dictionary:
  var keys = dict.keys()

  for key in keys:
    if key not in default:
      dict.erase(key)
    elif typeof(dict[key]) == TYPE_ARRAY and typeof(default[key]) == TYPE_ARRAY:
      if not Global.arrays_diff(dict[key], default[key]):
        dict.erase(key)
    elif typeof(dict[key]) == TYPE_DICTIONARY and typeof(default[key]) == TYPE_DICTIONARY:
      if not ignore_subdict_changes:
        dict[key] = clear_unchanged_dict_keys(dict[key], default[key])
      if dict[key].is_empty():
        dict.erase(key)
    elif dict[key] == default[key]:
      dict.erase(key)

  return dict