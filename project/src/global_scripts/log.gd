extends Node

func info(msg: Array, stack = null) -> void:
  _append(_timestamp() + " INFO: " + Global.array_to_string(msg + _stack(stack)))

func warning(msg: Array, stack = null) -> void:
  _append(_timestamp() + " WARNING: " + Global.array_to_string(msg + _stack(stack)))

func error(msg: Array, stack = null) -> void:
  _append(_timestamp() + " ERROR: " + Global.array_to_string(msg + _stack(stack)))

func debug(callback: Callable, msg: Array, stack = null) -> void:
  if OS.is_debug_build(): # TODO: This should be a config setting
    callback.call(msg, stack)

func function_call(prefix: String, params: Array, extra: Dictionary = {}) -> void:
  var msg := [prefix, "("]

  for i in range(params.size()):
    if i > 0: msg += [", "]

    var param: Variant = params[i]
    if param is String:
      msg += ["'", param, "'"]
    else:
      msg += [param]

  msg += [")"]

  if extra.size() > 0:
    for key in extra:
      msg += [" ::: ", key, " => ", extra[key]]

  info(msg, get_stack())

var _PATH := Global.get_manager_subpath("log.txt")
var _first_log := true

func _append(content: String) -> void:
  if _first_log:
    _first_log = false
    content = "=== New start ===\n" + content

  if not content.ends_with("\n"):
    content += "\n"

  FileSystem.ensure_dir_exists(FileSystem.get_directory(_PATH), false, true)
  FileSystem.append(_PATH, content, true, true)

func _timestamp() -> String:
  return "[" + Time.get_datetime_string_from_system(true, true) + "]"

func _stack(stack) -> Array:
  if stack == null:
    return []

  var retval := []
  for entry in stack:
    retval += ["\n    " + entry["source"] + " @ " + entry["function"] + " # " + str(entry["line"])]

  return retval
