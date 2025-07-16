class_name UnrealPakHelper

static func mod_file_with_prefix_exists(prefix: String) -> bool:
  return FileSystem.is_file(prefix + "_P.pak") or FileSystem.is_file(prefix + "_p.pak")

static func is_pak_file(file: String) -> bool:
  return file.ends_with("_P.pak") or file.ends_with("_p.pak")

static func is_mod_file(file: String, mod: String) -> bool:
  return file.begins_with(mod + "_P.") or file.begins_with(mod + "_p.")

static func get_mod_name_from_file(file: String) -> String:
  return FileSystem.get_filename(file, ["_P.pak", "_p.pak"])
