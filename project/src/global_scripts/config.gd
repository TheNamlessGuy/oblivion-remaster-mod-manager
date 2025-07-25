extends Node

signal setting_changed(key: Config.Key, old_value, new_value, persisted: bool)

# Note: if you add anything here aside from at the end, you have to update SettingsTab to use the new values
enum Key {
  UNKNOWN                                      = -1,

  # General
  INSTALL_DIRECTORY                            = 0,
  DEFAULT_TAB                                  = 1,
  DEFAULT_MODS_FOLDER                          = 2,
  DEFAULT_ADD_MODE                             = 3,
  DEFAULT_BACKUPS_FOLDER                       = 4,

  # ESP/ESM
  SHOW_ESP_ESM                                 = 5,
  ESP_ESM_DEFAULT_MODS_FOLDER                  = 6,
  ESP_ESM_DEFAULT_ADD_MODE                     = 7,
  ESP_ESM_DEFAULT_BACKUPS_FOLDER               = 8,

  # UnrealPak
  SHOW_UNREAL_PAK                              = 9,
  UNREAL_PAK_AVAILABLE_MODS_FOLDER             = 10,
  UNREAL_PAK_DEFAULT_MODS_FOLDER               = 11,
  UNREAL_PAK_DEFAULT_ADD_MODE                  = 12,

  # OBSE
  SHOW_OBSE                                    = 13,
  OBSE_AVAILABLE_MODS_FOLDER                   = 14,
  OBSE_DEFAULT_MODS_FOLDER                     = 15,
  OBSE_DEFAULT_ADD_MODE                        = 16,

  # UE4SS
  SHOW_UE4SS                                   = 17,
  UE4SS_DEFAULT_MODS_FOLDER                    = 18,
  UE4SS_DEFAULT_ADD_MODE                       = 19,

  # MagicLoader
  SHOW_MAGIC_LOADER                            = 20,
  MAGIC_LOADER_AVAILABLE_MODS_FOLDER           = 21,
  MAGIC_LOADER_DEFAULT_MODS_FOLDER             = 22,
  MAGIC_LOADER_DEFAULT_ADD_MODE                = 23,

  # TesSyncMapInjector
  SHOW_TES_SYNC_MAP_INJECTOR                   = 24,
  TES_SYNC_MAP_INJECTOR_AVAILABLE_MODS_FOLDER  = 25,
  TES_SYNC_MAP_INJECTOR_DEFAULT_MODS_FOLDER    = 26,
  TES_SYNC_MAP_INJECTOR_DEFAULT_ADD_MODE       = 27,

  # NPCAppearanceManager
  SHOW_NPC_APPEARANCE_MANAGER                  = 28,
  NPC_APPEARANCE_MANAGER_AVAILABLE_MODS_FOLDER = 29,
  NPC_APPEARANCE_MANAGER_DEFAULT_MODS_FOLDER   = 30,
  NPC_APPEARANCE_MANAGER_DEFAULT_ADD_MODE      = 31,
}

func flush() -> void:
  _write(_CACHE)

var install_directory: String:
  get: return get_by_key(Config.Key.INSTALL_DIRECTORY)
func set_install_directory(value: String, write: bool = true): set_by_key(Config.Key.INSTALL_DIRECTORY, value, write)

var default_tab: String:
  get: return get_by_key(Config.Key.DEFAULT_TAB)
func get_default_tab_id() -> Tab.Value: return Tab.settings_key_to_id(Config.default_tab)

func show_tab(tab: Tab.Value) -> bool:
  return {
    Tab.SETTINGS: true,
    Tab.ESP_ESM: get_by_key(Config.Key.SHOW_ESP_ESM),
    Tab.UNREAL_PAK: get_by_key(Config.Key.SHOW_UNREAL_PAK),
    Tab.OBSE: get_by_key(Config.Key.SHOW_OBSE),
    Tab.UE4SS: get_by_key(Config.Key.SHOW_UE4SS),
    Tab.MAGIC_LOADER: get_by_key(Config.Key.SHOW_MAGIC_LOADER),
    Tab.TES_SYNC_MAP_INJECTOR: get_by_key(Config.Key.SHOW_TES_SYNC_MAP_INJECTOR),
    Tab.NPC_APPEARANCE_MANAGER: get_by_key(Config.Key.SHOW_NPC_APPEARANCE_MANAGER),
  }[tab]

func get_default_add_mode_for_mod_type(mod_type: ModType.Value) -> AddMode.Value:
  return _generic_get_value_for_mod_type(mod_type, AddMode.UNKNOWN, Config.Key.DEFAULT_ADD_MODE, {
    ModType.ESP_ESM: Config.Key.ESP_ESM_DEFAULT_ADD_MODE,
    ModType.UNREAL_PAK: Config.Key.UNREAL_PAK_DEFAULT_ADD_MODE,
    ModType.OBSE: Config.Key.OBSE_DEFAULT_ADD_MODE,
    ModType.UE4SS: Config.Key.UE4SS_DEFAULT_ADD_MODE,
    ModType.MAGIC_LOADER: Config.Key.MAGIC_LOADER_DEFAULT_ADD_MODE,
    ModType.TES_SYNC_MAP_INJECTOR: Config.Key.TES_SYNC_MAP_INJECTOR_DEFAULT_ADD_MODE,
    ModType.NPC_APPEARANCE_MANAGER: Config.Key.DEFAULT_ADD_MODE,
  }, [AddMode.UNKNOWN])

func get_default_mods_folder_for_mod_type(mod_type: ModType.Value) -> String:
  return _generic_get_value_for_mod_type(mod_type, "", Config.Key.DEFAULT_MODS_FOLDER, {
    ModType.ESP_ESM: Config.Key.ESP_ESM_DEFAULT_MODS_FOLDER,
    ModType.UNREAL_PAK: Config.Key.UNREAL_PAK_DEFAULT_MODS_FOLDER,
    ModType.OBSE: Config.Key.OBSE_DEFAULT_MODS_FOLDER,
    ModType.UE4SS: Config.Key.UE4SS_DEFAULT_MODS_FOLDER,
    ModType.MAGIC_LOADER: Config.Key.MAGIC_LOADER_DEFAULT_MODS_FOLDER,
    ModType.TES_SYNC_MAP_INJECTOR: Config.Key.TES_SYNC_MAP_INJECTOR_DEFAULT_MODS_FOLDER,
    ModType.NPC_APPEARANCE_MANAGER: Config.Key.NPC_APPEARANCE_MANAGER_DEFAULT_MODS_FOLDER,
  })

func get_default_backups_folder_for_mod_type(mod_type: ModType.Value) -> String:
  return _generic_get_value_for_mod_type(mod_type, "", Config.Key.DEFAULT_BACKUPS_FOLDER, {
    ModType.ESP_ESM: Config.Key.ESP_ESM_DEFAULT_BACKUPS_FOLDER,
  })

var unreal_pak_available_mods_folder: String:
  get: return get_by_key(Config.Key.UNREAL_PAK_AVAILABLE_MODS_FOLDER)

var obse_available_mods_folder: String:
  get: return get_by_key(Config.Key.OBSE_AVAILABLE_MODS_FOLDER)

var magic_loader_available_mods_folder: String:
  get: return get_by_key(Config.Key.MAGIC_LOADER_AVAILABLE_MODS_FOLDER)

var tes_sync_map_injector_available_mods_folder: String:
  get: return get_by_key(Config.Key.TES_SYNC_MAP_INJECTOR_AVAILABLE_MODS_FOLDER)

var npc_appearance_manager_available_mods_folder: String:
  get: return get_by_key(Config.Key.NPC_APPEARANCE_MANAGER_AVAILABLE_MODS_FOLDER)

var _PATH := Global.get_manager_subpath("config.json")
var _DEFAULT: Dictionary = {
  # General
  _enum_key_to_str(Config.Key.INSTALL_DIRECTORY): "",
  _enum_key_to_str(Config.Key.DEFAULT_TAB): Tab.id_to_settings_key(Tab.SETTINGS),
  _enum_key_to_str(Config.Key.DEFAULT_MODS_FOLDER): OS.get_system_dir(OS.SystemDir.SYSTEM_DIR_DOWNLOADS),
  _enum_key_to_str(Config.Key.DEFAULT_ADD_MODE): AddMode.MOVE_ON_ADD,
  _enum_key_to_str(Config.Key.DEFAULT_BACKUPS_FOLDER): Global.get_manager_subpath("Backups"),

  # ESP/ESM
  _enum_key_to_str(Config.Key.SHOW_ESP_ESM): true,
  _enum_key_to_str(Config.Key.ESP_ESM_DEFAULT_MODS_FOLDER): null,
  _enum_key_to_str(Config.Key.ESP_ESM_DEFAULT_ADD_MODE): AddMode.UNKNOWN,
  _enum_key_to_str(Config.Key.ESP_ESM_DEFAULT_BACKUPS_FOLDER): null,

  # UnrealPak
  _enum_key_to_str(Config.Key.SHOW_UNREAL_PAK): true,
  _enum_key_to_str(Config.Key.UNREAL_PAK_AVAILABLE_MODS_FOLDER): Global.get_manager_subpath("Available UnrealPak mods"),
  _enum_key_to_str(Config.Key.UNREAL_PAK_DEFAULT_MODS_FOLDER): null,
  _enum_key_to_str(Config.Key.UNREAL_PAK_DEFAULT_ADD_MODE): AddMode.UNKNOWN,

  # OBSE
  _enum_key_to_str(Config.Key.SHOW_OBSE): true,
  _enum_key_to_str(Config.Key.OBSE_AVAILABLE_MODS_FOLDER): Global.get_manager_subpath("Available OBSE mods"),
  _enum_key_to_str(Config.Key.OBSE_DEFAULT_MODS_FOLDER): null,
  _enum_key_to_str(Config.Key.OBSE_DEFAULT_ADD_MODE): AddMode.UNKNOWN,

  # UE4SS
  _enum_key_to_str(Config.Key.SHOW_UE4SS): true,
  _enum_key_to_str(Config.Key.UE4SS_DEFAULT_MODS_FOLDER): null,
  _enum_key_to_str(Config.Key.UE4SS_DEFAULT_ADD_MODE): AddMode.UNKNOWN,

  # MagicLoader
  _enum_key_to_str(Config.Key.SHOW_MAGIC_LOADER): true,
  _enum_key_to_str(Config.Key.MAGIC_LOADER_AVAILABLE_MODS_FOLDER): Global.get_manager_subpath("Available MagicLoader mods"),
  _enum_key_to_str(Config.Key.MAGIC_LOADER_DEFAULT_MODS_FOLDER): null,
  _enum_key_to_str(Config.Key.MAGIC_LOADER_DEFAULT_ADD_MODE): AddMode.UNKNOWN,

  # TesSyncMapInjector
  _enum_key_to_str(Config.Key.SHOW_TES_SYNC_MAP_INJECTOR): true,
  _enum_key_to_str(Config.Key.TES_SYNC_MAP_INJECTOR_AVAILABLE_MODS_FOLDER): Global.get_manager_subpath("Available TesSyncMapInjector mods"),
  _enum_key_to_str(Config.Key.TES_SYNC_MAP_INJECTOR_DEFAULT_MODS_FOLDER): null,
  _enum_key_to_str(Config.Key.TES_SYNC_MAP_INJECTOR_DEFAULT_ADD_MODE): AddMode.UNKNOWN,

  # NPCAppearanceManager
  _enum_key_to_str(Config.Key.SHOW_NPC_APPEARANCE_MANAGER): true,
  _enum_key_to_str(Config.Key.NPC_APPEARANCE_MANAGER_AVAILABLE_MODS_FOLDER): Global.get_manager_subpath("Available NPCAppearanceManager mods"),
  _enum_key_to_str(Config.Key.NPC_APPEARANCE_MANAGER_DEFAULT_MODS_FOLDER): null,
  _enum_key_to_str(Config.Key.NPC_APPEARANCE_MANAGER_DEFAULT_ADD_MODE): AddMode.UNKNOWN,
}

func _write(data: Dictionary) -> void:
  data = Global.clear_unchanged_dict_keys(data, _DEFAULT)

  if data.is_empty():
    if FileSystem.is_file(_PATH): FileSystem.remove(_PATH)
  else:
    FileSystem.ensure_dir_exists(FileSystem.get_directory(_PATH))
    FileSystem.write_json(_PATH, data)

func _read() -> Dictionary:
  if not FileSystem.exists(_PATH):
    return {}

  var data := FileSystem.read_json(_PATH)
  data = Global.clear_unchanged_dict_keys(data, _DEFAULT)
  return data

var _CACHE: Variant = null
func _cache() -> Dictionary:
  if _CACHE == null:
    _CACHE = _read()

  return _CACHE

func get_by_key(key: Config.Key) -> Variant:
  var key_str := _enum_key_to_str(key)

  var cache := _cache()
  if cache.has(key_str):
    return cache[key_str]
  return _DEFAULT[key_str]

func get_default_by_key(key: Config.Key) -> Variant:
  return _DEFAULT[_enum_key_to_str(key)]

func set_by_key(key: Config.Key, value, write: bool = true) -> void:
  var old_value: Variant = get_by_key(key)
  if old_value == value:
    return

  _CACHE[_enum_key_to_str(key)] = value
  if write: _write(_CACHE)
  setting_changed.emit(key, old_value, value, write)

func _generic_get_value_for_mod_type(mod_type: ModType.Value, default, base, mod_type_map: Dictionary, invalid_values: Array = [null]):
  if not mod_type_map.has(mod_type):
    Global.fatal_error(["Encountered unknown mod type '", mod_type, "' in Config::_generic_get_value_for_mod_type"])

  var value: Variant = get_by_key(mod_type_map[mod_type])
  if value not in invalid_values:
    return value

  value = get_by_key(base)
  if value not in invalid_values:
    return value

  return default

func _enum_key_to_str(key: Config.Key) -> String:
  return Config.Key.find_key(key).to_lower()
