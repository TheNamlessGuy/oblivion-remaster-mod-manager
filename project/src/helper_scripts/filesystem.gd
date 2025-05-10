class_name FileSystem

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

static func get_filename(path_to_file: String, file_ends_to_remove: Array[String] = []) -> String:
  var filename: String = Array(path_to_file.split("/")).pop_back()
  for end in file_ends_to_remove:
    filename = filename.replace(end, "")
  return filename

static func get_directory(path_to_file: String) -> String:
  return path_to_file.replace("/" + get_filename(path_to_file), "")

static func get_directory_name(path_to_file: String) -> String:
  return get_filename(get_directory(path_to_file))

static func mkdir(path_to_directory: String, recursive: bool = true) -> void:
  if recursive:
    DirAccess.make_dir_recursive_absolute(path_to_directory)
  else:
    DirAccess.make_dir_absolute(path_to_directory)

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
  var file := FileAccess.open(path_to_file, FileAccess.WRITE)
  if file == null:
    Global.fatal_error(["Failed to open file '", path_to_file, "' for write"])

  file.store_string(content)
  file.close()

static func append(path_to_file: String, content: String, create_if_nonexistant: bool = false) -> void:
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

static func files_in(path_to_dir: String) -> Array: return Array(DirAccess.get_files_at(path_to_dir))
static func directories_in(path_to_dir: String) -> Array: return Array(DirAccess.get_directories_at(path_to_dir))
static func directory_contents(path_to_dir: String) -> Array: return directories_in(path_to_dir) + files_in(path_to_dir)

static func trash(path_to_trash: String) -> void: OS.move_to_trash(path_to_trash)
static func remove(path_to_remove: String) -> void: DirAccess.remove_absolute(path_to_remove)
static func move(from: String, to: String) -> void: DirAccess.rename_absolute(from, to)
static func copy(from: String, to: String) -> void:
  if is_dir(from):
    _copy_dir_recursive(from, to) # DirAccess.copy_absolute only works for files, so we have to manually copy the folder over
  else:
    DirAccess.copy_absolute(from, to)

static func _copy_dir_recursive(from: String, to: String) -> void:
  mkdir(to)

  var dirs := directories_in(from)
  for dir in dirs:
    _copy_dir_recursive(path([from, dir]), path([to, dir]))

  var files := files_in(from)
  for file in files:
    copy(path([from, file]), path([to, file]))
