extends Node

enum OperatingSystem {
  UNKNOWN = -1,
  WINDOWS = 0,
  LINUX   = 1,
}

func _ready() -> void:
  get_viewport().get_window().min_size = Vector2i(640, 480) # TODO: This seemingly doesn't do anything

func exit(exit_code) -> void:
  var tree := get_tree()
  tree.root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
  tree.quit(exit_code)

func fatal_error(msg: Array) -> void:
  OS.alert(array_to_string(msg), "Internal fatal error")
  Log.error(msg, get_stack())
  exit(1)

func array_to_string(array: Array) -> String:
  var retval := ""
  for item in array:
    retval += str(item)
  return retval

func get_project_name() -> String:
  return ProjectSettings.get_setting("application/config/name")

func get_executable_name(file_ends_to_remove = [".exe", ".x86_64"]) -> String:
  if OS.is_debug_build():
    return "namless-oblivion-remaster-mod-manager"
  return FileSystem.get_filename(OS.get_executable_path(), file_ends_to_remove)

func get_executable_directory() -> String:
  if OS.is_debug_build():
    return ProjectSettings.globalize_path("res://")
  return FileSystem.get_directory(OS.get_executable_path())

func get_manager_folder() -> String:
  var actual_executable_name := get_executable_name([])
  var executable_name := get_executable_name()
  if actual_executable_name == executable_name:
    # We don't want the manager folder to have the same name as the executable file, as (at least in most file systems), you can't have a file and a folder with the same name in the same location.
    executable_name += '.d'
  return FileSystem.path([get_executable_directory(), executable_name])
func get_manager_subpath(file: String) -> String: return FileSystem.path([get_manager_folder(), file])

func get_os() -> OperatingSystem:
  match OS.get_name():
    "Windows": return OperatingSystem.WINDOWS
    "Linux": return OperatingSystem.LINUX
    _: return OperatingSystem.UNKNOWN

func arrays_diff(arr1: Array, arr2: Array) -> bool:
  if arr1.size() != arr2.size():
    return true

  for i in range(arr1.size()):
    if arr1[i] != arr2[i]:
      return true

  return false

func diff_arrays(arr1: Array, arr2: Array) -> Array:
  var retval := []

  for entry in arr1:
    if entry not in arr2:
      retval.push_back(entry)

  return retval

func clear_unchanged_dict_keys(dict: Dictionary, default: Dictionary, ignore_subdict_changes: bool = false) -> Dictionary:
  var keys := dict.keys()

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

func current_timestamp_to_filename() -> String:
  return timestamp_to_filename(Time.get_datetime_dict_from_system())
func timestamp_to_filename(timestamp_dict: Dictionary) -> String:
  var year := str(timestamp_dict["year"])
  var month := str(timestamp_dict["month"]).lpad(2, "0")
  var day := str(timestamp_dict["day"]).lpad(2, "0")
  var hour := str(timestamp_dict["hour"]).lpad(2, "0")
  var minute := str(timestamp_dict["minute"]).lpad(2, "0")
  var second := str(timestamp_dict["second"]).lpad(2, "0")
  return Global.array_to_string([year, "-", month, "-", day, "-", hour, "-", minute, "-", second])

class _RunProgramResponse:
  var exit_code: int = -1
  var stdout: String = ""
  var stderr: String = ""

func run_program(path_to_exe: String, args: Array = []) -> _RunProgramResponse:
  var retval := _RunProgramResponse.new()

  var output := []
  retval.exit_code = OS.execute(path_to_exe, PackedStringArray(args), output, true)
  if retval.exit_code == -1:
    fatal_error(["Failed to execute '", path_to_exe, "' with arguments '", "', '".join(args), "'"])
    return retval

  if output.size() > 0: retval.stdout = output[0]
  if output.size() > 1: retval.stderr = output[1]
  return retval
