extends Node

func info(msg: Array, stack = null) -> void:
  _append(_timestamp() + " INFO: " + Global.array_to_string(msg + _stack(stack)))

func warning(msg: Array, stack = null) -> void:
  _append(_timestamp() + " WARNING: " + Global.array_to_string(msg + _stack(stack)))

func error(msg: Array, stack = null) -> void:
  _append(_timestamp() + " ERROR: " + Global.array_to_string(msg + _stack(stack)))

var _PATH = Global.get_manager_subpath("log.txt")
var _first_log = true

func _append(content: String) -> void:
  if _first_log:
    _first_log = false
    content = "=== New start ===\n" + content

  if not content.ends_with("\n"):
    content += "\n"

  FileSystem.mkdir(FileSystem.get_directory(_PATH))
  FileSystem.append(_PATH, content, true)

func _timestamp() -> String:
  return "[" + Time.get_datetime_string_from_system(true, true) + "]"

func _stack(stack) -> Array:
  if stack == null:
    return []

  var retval = []
  for entry in stack:
    retval += ["\n    " + entry["source"] + " @ " + entry["function"] + " # " + str(entry["line"])]

  return retval
