class_name UE4SSHelper

const MOD_NAME := 0
const MOD_ACTIVATED := 1

static func mods_dir_exists(install_dir: String = "") -> bool: return FileSystem.is_dir(get_mods_dir(install_dir))
static func is_active(install_dir: String = "") -> bool: return mods_dir_exists(install_dir)

static func get_mods_dir(install_dir: String = "") -> String:
  return FileSystem.path([Game.get_bin_path(install_dir), "ue4ss", "Mods"])

static func get_mods_file(install_dir: String = "") -> String:
  return FileSystem.path([get_mods_dir(install_dir), "mods.txt"])

static func get_active_mod_dir(mod: String, install_dir: String = "") -> String:
  return FileSystem.path([get_mods_dir(install_dir), mod])

static func get_mods_in_mods_file(install_dir: String = "") -> Array:
  var retval := []
  var lines := FileSystem.read_lines(UE4SSHelper.get_mods_file(install_dir))
  for line in lines:
    if " : " not in line:
      continue

    var split := Array(line.split(" : "))
    split[MOD_ACTIVATED] = split[MOD_ACTIVATED] == "1"
    retval.push_back(split)

  return retval

static func mod_is_active(mod_name: String, install_dir: String = "") -> bool:
  var mods := get_mods_in_mods_file(install_dir)

  for mod in mods:
    if mod[MOD_NAME] == mod_name:
      return mod[MOD_ACTIVATED]

  return false

static func shared_lib_exists(lib_name: String, install_dir: String = "") -> bool:
  return lib_name in FileSystem.directories_in(FileSystem.path([get_mods_dir(install_dir), "shared"]))
