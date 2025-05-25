class_name FileSystem

## For debugging purposes
static var _DISABLE_ACTIONS = false

static func path(arr: Array) -> String:
  if arr.size() == 0: return ""

  var retval: String = arr.pop_front()
  for entry in arr:
    var begins: bool = entry.begins_with("/")
    var ends: bool = retval.ends_with("/")
    if begins != ends:
      pass # No-op
    elif not begins: # and not ends
      retval += "/"
    else:
      entry = entry.erase(0, 1)
    retval += entry

  return retval

static func path_depth(path_to_measure: String) -> int: return path_to_measure.split("/").size()

static func get_filename(path_to_file: String, file_ends_to_remove: Array[String] = []) -> String:
  var filename: String = Array(path_to_file.split("/")).pop_back()
  for end in file_ends_to_remove:
    filename = filename.replace(end, "")
  return filename

static func get_directory(path_to_file: String) -> String:
  return path_to_file.replace("/" + get_filename(path_to_file), "")

static func get_directory_name(path_to_file: String) -> String:
  return get_filename(get_directory(path_to_file))

static func get_paths_with_swapped_directories(paths: Array, from_dir: String, to_dir: String) -> Array:
  if not from_dir.ends_with("/"): from_dir += "/"
  if not to_dir.ends_with("/"): to_dir += "/"

  var retval := []
  for p in paths:
    var tmp = p
    if not tmp.ends_with("/"): tmp += "/"

    if tmp == from_dir:
      retval.push_back(to_dir)
    else:
      retval.push_back(p.replace(from_dir, to_dir))

  return retval

static func ensure_dir_exists(path_to_directory: String, recursive: bool = true, from_log: bool = false) -> void:
  if _DISABLE_ACTIONS and not from_log:
    Log.function_call("FileSystem.ensure_dir_exists", [path_to_directory, recursive])
    return

  if recursive:
    var result := DirAccess.make_dir_recursive_absolute(path_to_directory)
    if result not in [OK, ERR_ALREADY_EXISTS]: Global.fatal_error(["Failed to recursively make directory '", path_to_directory, "'. Error code: ", result])
  else:
    var result := DirAccess.make_dir_absolute(path_to_directory)
    if result not in [OK, ERR_ALREADY_EXISTS]: Global.fatal_error(["Failed to make directory '", path_to_directory, "'. Error code: ", result])

static func line_separator_format(content: String) -> String:
  if content.contains("\n\r"):
    return "\n\r"
  elif content.contains("\r\n"):
    return "\r\n"
  elif content.contains("\n"):
    return "\n"
  else:
    Global.fatal_error(["Unknown line separator format found"])
    return ""

static func split_into_lines(content: String) -> Array:
  return Array(content.split(line_separator_format(content)))

static func read(path_to_file: String) -> String:
  var file := FileAccess.open(path_to_file, FileAccess.READ)
  if file == null:
    Global.fatal_error(["Failed to open file '", path_to_file, "' for read"])

  var content := file.get_as_text()
  file.close()
  return content

static func read_lines(path_to_file: String) -> Array:
  return split_into_lines(read(path_to_file))

static func read_json(path_to_file: String) -> Dictionary:
  return JSON.parse_string(read(path_to_file))

static func write(path_to_file: String, content: String) -> void:
  if _DISABLE_ACTIONS:
    Log.function_call("FileSystem.write", [path_to_file, content])
    return

  var file := FileAccess.open(path_to_file, FileAccess.WRITE)
  if file == null:
    Global.fatal_error(["Failed to open file '", path_to_file, "' for write"])

  file.store_string(content)
  file.close()

static func append(path_to_file: String, content: String, create_if_nonexistant: bool = false, from_log: bool = false) -> void:
  if _DISABLE_ACTIONS and not from_log:
    Log.function_call("FileSystem.append", [path_to_file, content, create_if_nonexistant])
    return

  var file := FileAccess.open(path_to_file, FileAccess.READ_WRITE)
  if file == null:
    if create_if_nonexistant and not is_file(path_to_file):
      file = FileAccess.open(path_to_file, FileAccess.WRITE)
    else:
      Global.fatal_error(["Failed to open file '", path_to_file, "' for append"])

  file.seek_end()
  file.store_string(content)
  file.close()

static func write_lines(path_to_file: String, lines: Array, newline_symbol: String = "\n") -> void:
  write(path_to_file, newline_symbol.join(lines))

static func write_json(path_to_file: String, data: Dictionary, indent: String = "  ") -> void:
  write(path_to_file, JSON.stringify(data, indent))

static func is_file(path_to_file: String) -> bool: return path_to_file.length() > 0 && FileAccess.file_exists(path_to_file)
static func is_dir(path_to_file: String) -> bool: return path_to_file.length() > 0 && DirAccess.dir_exists_absolute(path_to_file)
static func exists(path_to_file: String) -> bool: return is_file(path_to_file) or is_dir(path_to_file)
static func dir_is_empty(path_to_check: String) -> bool: return directory_contents(path_to_check).size() == 0

static func files_in(path_to_dir: String, recursive: bool = false) -> Array:
  if recursive:
    return _files_in_recursive(path_to_dir, path_to_dir)
  return Array(DirAccess.get_files_at(path_to_dir))

static func directories_in(path_to_dir: String, recursive: bool = false) -> Array:
  if recursive:
    return _directories_in_recursive(path_to_dir, path_to_dir)
  return Array(DirAccess.get_directories_at(path_to_dir))

static func directory_contents(path_to_dir: String, recursive: bool = false) -> Array:
  if recursive:
    return _directory_contents_recursive(path_to_dir, path_to_dir)
  return directories_in(path_to_dir) + files_in(path_to_dir)

static func trash(path_to_trash: String) -> void:
  if _DISABLE_ACTIONS:
    Log.function_call("FileSystem.trash", [path_to_trash])
    return

  var result := OS.move_to_trash(path_to_trash)
  if result != OK: Global.fatal_error(["Failed to trash '", path_to_trash, "'. Error code: ", result])

static func remove(path_to_remove: String) -> void:
  if _DISABLE_ACTIONS:
    Log.function_call("FileSystem.remove", [path_to_remove])
    return

  var result := DirAccess.remove_absolute(path_to_remove)
  if result != OK: Global.fatal_error(["Failed to remove '", path_to_remove, "'. Error code: ", result])

static func move(from: String, to: String, create_to_parent_directory_if_doesnt_exist: bool = false) -> void:
  if _DISABLE_ACTIONS:
    Log.function_call("FileSystem.move", [from, to, create_to_parent_directory_if_doesnt_exist])
    return

  if create_to_parent_directory_if_doesnt_exist:
    _create_parent_directory_if_doesnt_exist(to)

  var result := DirAccess.rename_absolute(from, to)
  if result != OK: Global.fatal_error(["Failed to move '", from, "' to '", to, "'. Error code: ", result])

static func copy(from: String, to: String, create_to_parent_directory_if_doesnt_exist: bool = false) -> void:
  if _DISABLE_ACTIONS:
    Log.function_call("FileSystem.copy", [from, to, create_to_parent_directory_if_doesnt_exist])
    return

  if create_to_parent_directory_if_doesnt_exist:
    _create_parent_directory_if_doesnt_exist(to)

  # DirAccess.copy_absolute only works for files, so we have to manually copy the folder over
  if is_dir(from):
    _copy_dir_recursive(from, to)
  else:
    var result := DirAccess.copy_absolute(from, to)
    if result != OK: Global.fatal_error(["Failed to copy '", from, "' to '", to, "'. Error code: ", result])

static func _create_parent_directory_if_doesnt_exist(path_to_fix: String) -> void:
  var parent := get_directory(path_to_fix)
  if not is_dir(parent):
    ensure_dir_exists(parent)

static func _copy_dir_recursive(from: String, to: String) -> void:
  ensure_dir_exists(to)

  var dirs := directories_in(from)
  for dir in dirs:
    _copy_dir_recursive(path([from, dir]), path([to, dir]))

  var files := files_in(from)
  for file in files:
    copy(path([from, file]), path([to, file]))

static func _files_in_recursive(path_to_dir: String, root: String) -> Array:
  var rootless_path := path_to_dir.replace(root, "")
  while rootless_path.begins_with("/"): rootless_path = rootless_path.substr(1)

  var files := files_in(path_to_dir).map(func(file: String) -> String: return path([rootless_path, file]))

  var dirs := directories_in(path_to_dir)
  for dir in dirs:
    files += _files_in_recursive(path([path_to_dir, dir]), root)

  return files

static func _directories_in_recursive(path_to_dir: String, root: String) -> Array:
  var rootless_path := path_to_dir.replace(root, "")
  while rootless_path.begins_with("/"): rootless_path = rootless_path.substr(1)

  var dirs := directories_in(path_to_dir)

  var retval := dirs.map(func(dir: String) -> String: return path([rootless_path, dir]))
  for dir in dirs:
    retval += _directories_in_recursive(path([path_to_dir, dir]), root)

  return retval

static func _directory_contents_recursive(path_to_dir: String, root: String) -> Array:
  var rootless_path := path_to_dir.replace(root, "")
  while rootless_path.begins_with("/"): rootless_path = rootless_path.substr(1)

  var rootify = func(p: String) -> String:
    if rootless_path.length() == 0: return p
    return path([rootless_path, p])

  var retval := files_in(path_to_dir).map(rootify)
  var dirs := directories_in(path_to_dir)
  for dir in dirs:
    var full_path := path([path_to_dir, dir])
    retval += [rootify.call(dir)]
    retval += _directory_contents_recursive(full_path, root)

  return retval
