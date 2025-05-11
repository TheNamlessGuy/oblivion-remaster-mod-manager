extends Node

enum InstallType {
  UNKNOWN  = -1,

  STEAM    = 0,
  GAMEPASS = 1,
}

func get_install_type(install_directory: String = "") -> InstallType:
  if install_directory.length() == 0: install_directory = Config.install_directory

  if _directory_is_steam_install(install_directory):
    return InstallType.STEAM
  elif _directory_is_gamepass_install(install_directory):
    return InstallType.GAMEPASS

  return InstallType.UNKNOWN

func install_directory_is_valid(dir: String = "", for_type: InstallType = InstallType.UNKNOWN) -> bool:
  if dir.length() == 0: dir = Config.install_directory

  if for_type == InstallType.UNKNOWN:
    return get_install_type(dir) != InstallType.UNKNOWN

  return for_type == get_install_type(dir)

func get_data_dir(install_dir: String = "") -> String:
  if install_dir.length() == 0: install_dir = Config.install_directory
  return FileSystem.path([install_dir, "OblivionRemastered", "Content", "Dev", "ObvData", "Data"])

func get_pak_dir(install_dir: String = "") -> String:
  if install_dir.length() == 0: install_dir = Config.install_directory
  return FileSystem.path([install_dir, "OblivionRemastered", "Content", "Paks"])

func get_bin_path(install_dir: String = "", type: InstallType = InstallType.UNKNOWN) -> String:
  if install_dir.length() == 0: install_dir = Config.install_directory
  if type == InstallType.UNKNOWN: type = get_install_type(install_dir)

  if type == InstallType.STEAM:
    return FileSystem.path([install_dir, "OblivionRemastered", "Binaries", "Win64"])
  elif type == InstallType.GAMEPASS:
    return FileSystem.path([install_dir, "OblivionRemastered", "Binaries", "WinGDK"])

  return ""

func _directory_is_steam_install(dir: String) -> bool:
  return FileSystem.is_file(FileSystem.path([dir, "OblivionRemastered.exe"]))

func _directory_is_gamepass_install(dir: String) -> bool:
  return FileSystem.is_file(FileSystem.path([dir, "gamelaunchhelper.exe"]))
