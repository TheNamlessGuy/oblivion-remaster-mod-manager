extends Node

signal setting_changed(key: Config.Key, old_value, new_value, persisted: bool)

# Note: if you add anything here aside from at the end, you have to update SettingsTab to use the new values
enum Key {
  UNKNOWN                                                       = -1,

  # General
  INSTALL_DIRECTORY                                             = 0,
  DEFAULT_TAB                                                   = 1,
  DEFAULT_MODS_FOLDER                                           = 2,
  DEFAULT_ADD_MODE                                              = 3,

  # ESP/ESM
  SHOW_ESP_ESM                                                  = 4,
  ESP_ESM_DEFAULT_MODS_FOLDER                                   = 5,
  ESP_ESM_DEFAULT_ADD_MODE                                      = 6,
  ESP_ESM_CHOICE_ADD_MOD_CONFLICT                               = 7,
  ESP_ESM_CHOICE_MOD_ACTIVATED_CONFLICT                         = 8,
  ESP_ESM_CHOICE_MOD_DEACTIVATED_CONFLICT                       = 9,

  # UnrealPak
  SHOW_UNREAL_PAK                                               = 10,
  UNREAL_PAK_AVAILABLE_MODS_FOLDER                              = 11,
  UNREAL_PAK_DEFAULT_MODS_FOLDER                                = 12,
  UNREAL_PAK_DEFAULT_ADD_MODE                                   = 13,
  UNREAL_PAK_CHOICE_ADD_MOD_CONFLICT                            = 14,
  UNREAL_PAK_CHOICE_MOD_ACTIVATED_CONFLICT                      = 15,
  UNREAL_PAK_CHOICE_REGULAR_MOD_DEACTIVATED_CONFLICT            = 16,
  UNREAL_PAK_CHOICE_COPY_ON_ACTIVATION_MOD_DEACTIVATED_CONFLICT = 17,

  # OBSE
  SHOW_OBSE                                                     = 18,
  OBSE_AVAILABLE_MODS_FOLDER                                    = 19,
  OBSE_DEFAULT_MODS_FOLDER                                      = 20,
  OBSE_DEFAULT_ADD_MODE                                         = 21,
  OBSE_CHOICE_ADD_MOD_CONFLICT                                  = 22,
  OBSE_CHOICE_MOD_ACTIVATED_CONFLICT                            = 23,
  OBSE_CHOICE_REGULAR_MOD_DEACTIVATED_CONFLICT                  = 24,
  OBSE_CHOICE_COPY_ON_ACTIVATION_MOD_DEACTIVATED_CONFLICT       = 25,

  # UE4SS
  SHOW_UE4SS                                                    = 26,
  UE4SS_DEFAULT_MODS_FOLDER                                     = 27,
  UE4SS_DEFAULT_ADD_MODE                                        = 28,
  UE4SS_CHOICE_ADD_MOD_CONFLICT                                 = 29,
  UE4SS_CHOICE_MOD_ACTIVATED_CONFLICT                           = 30,
  UE4SS_CHOICE_MOD_DEACTIVATED_CONFLICT                         = 31,
}

func flush() -> void:
  _write(_CACHE)

var install_directory: String:
  get: return get_by_key(Config.Key.INSTALL_DIRECTORY)

var default_tab: String:
  get: return get_by_key(Config.Key.DEFAULT_TAB)
func get_default_tab_id() -> Tab.Value: return Tab.settings_key_to_id(Config.default_tab)

var unreal_pak_regular_mod_deactivated_conflict_choice_for_mod_type: ModDeactivatedConflict.Value:
  get: return get_by_key(Config.Key.UNREAL_PAK_CHOICE_REGULAR_MOD_DEACTIVATED_CONFLICT)

var unreal_pak_copy_on_activation_mod_deactivated_conflict_choice_for_mod_type: ModDeactivatedConflict.Value:
  get: return get_by_key(Config.Key.UNREAL_PAK_CHOICE_COPY_ON_ACTIVATION_MOD_DEACTIVATED_CONFLICT)

var obse_regular_mod_deactivated_conflict_choice_for_mod_type: ModDeactivatedConflict.Value:
  get: return get_by_key(Config.Key.OBSE_CHOICE_REGULAR_MOD_DEACTIVATED_CONFLICT)

var obse_copy_on_activation_mod_deactivated_conflict_choice_for_mod_type: ModDeactivatedConflict.Value:
  get: return get_by_key(Config.Key.OBSE_CHOICE_COPY_ON_ACTIVATION_MOD_DEACTIVATED_CONFLICT)

func show_tab(tab: Tab.Value) -> bool:
  return {
    Tab.SETTINGS: true,
    Tab.ESP_ESM: get_by_key(Config.Key.SHOW_ESP_ESM),
    Tab.UNREAL_PAK: get_by_key(Config.Key.SHOW_UNREAL_PAK),
    Tab.OBSE: get_by_key(Config.Key.SHOW_OBSE),
    Tab.UE4SS: get_by_key(Config.Key.SHOW_UE4SS),
  }[tab]

func get_default_add_mode_for_mod_type(mod_type: ModType.Value) -> AddMode.Value:
  return _generic_get_value_for_mod_type(mod_type, AddMode.UNKNOWN, Config.Key.DEFAULT_ADD_MODE, {
    ModType.ESP_ESM: Config.Key.ESP_ESM_DEFAULT_ADD_MODE,
    ModType.UNREAL_PAK: Config.Key.UNREAL_PAK_DEFAULT_ADD_MODE,
    ModType.OBSE: Config.Key.OBSE_DEFAULT_ADD_MODE,
    ModType.UE4SS: Config.Key.UE4SS_DEFAULT_ADD_MODE,
  }, [AddMode.UNKNOWN])

func get_default_mods_folder_mod_type(mod_type: ModType.Value) -> String:
  return _generic_get_value_for_mod_type(mod_type, "", Config.Key.DEFAULT_MODS_FOLDER, {
    ModType.ESP_ESM: Config.Key.ESP_ESM_DEFAULT_MODS_FOLDER,
    ModType.UNREAL_PAK: Config.Key.UNREAL_PAK_DEFAULT_MODS_FOLDER,
    ModType.OBSE: Config.Key.OBSE_DEFAULT_MODS_FOLDER,
    ModType.UE4SS: Config.Key.UE4SS_DEFAULT_MODS_FOLDER,
  })

func get_add_mod_conflict_choice_for_mod_type(mod_type: ModType.Value) -> AddModeConflict.Value:
  return _generic_get_value_for_mod_type(mod_type, AddModeConflict.UNKNOWN, Config.Key.UNKNOWN, {
    ModType.ESP_ESM: Config.Key.ESP_ESM_CHOICE_ADD_MOD_CONFLICT,
    ModType.UNREAL_PAK: Config.Key.UNREAL_PAK_CHOICE_ADD_MOD_CONFLICT,
    ModType.OBSE: Config.Key.OBSE_CHOICE_ADD_MOD_CONFLICT,
    ModType.UE4SS: Config.Key.UE4SS_CHOICE_ADD_MOD_CONFLICT,
  }, [AddModeConflict.UNKNOWN])

func get_mod_activated_conflict_choice_for_mod_type(mod_type: ModType.Value) -> ModActivatedConflict.Value:
  return _generic_get_value_for_mod_type(mod_type, ModActivatedConflict.UNKNOWN, Config.Key.UNKNOWN, {
    ModType.ESP_ESM: Config.Key.ESP_ESM_CHOICE_MOD_ACTIVATED_CONFLICT,
    ModType.UNREAL_PAK: Config.Key.UNREAL_PAK_CHOICE_MOD_ACTIVATED_CONFLICT,
    ModType.OBSE: Config.Key.OBSE_CHOICE_MOD_ACTIVATED_CONFLICT,
    ModType.UE4SS: Config.Key.UE4SS_CHOICE_MOD_ACTIVATED_CONFLICT,
  }, [ModActivatedConflict.UNKNOWN])

func get_mod_deactivated_conflict_choice_for_mod_type(mod_type: ModType.Value) -> ModDeactivatedConflict.Value:
  return _generic_get_value_for_mod_type(mod_type, ModDeactivatedConflict.UNKNOWN, Config.Key.UNKNOWN, {
    ModType.ESP_ESM: Config.Key.ESP_ESM_CHOICE_MOD_DEACTIVATED_CONFLICT,
    ModType.UE4SS: Config.Key.UE4SS_CHOICE_MOD_DEACTIVATED_CONFLICT,
  }, [ModDeactivatedConflict.UNKNOWN])

var unreal_pak_available_mods_folder: String:
  get: return get_by_key(Config.Key.UNREAL_PAK_AVAILABLE_MODS_FOLDER)

var obse_available_mods_folder: String:
  get: return get_by_key(Config.Key.OBSE_AVAILABLE_MODS_FOLDER)

var _PATH = Global.get_manager_subpath("config.json")
var _DEFAULT: Dictionary = {
  # General
  _enum_key_to_str(Config.Key.INSTALL_DIRECTORY): "C:/Program Files (x86)/Steam/steamapps/common/Oblivion Remastered",
  _enum_key_to_str(Config.Key.DEFAULT_TAB): Tab.id_to_settings_key(Tab.SETTINGS),
  _enum_key_to_str(Config.Key.DEFAULT_MODS_FOLDER): OS.get_system_dir(OS.SystemDir.SYSTEM_DIR_DOWNLOADS),
  _enum_key_to_str(Config.Key.DEFAULT_ADD_MODE): AddMode.MOVE_ON_ADD,

  # ESP/ESM
  _enum_key_to_str(Config.Key.SHOW_ESP_ESM): true,
  _enum_key_to_str(Config.Key.ESP_ESM_DEFAULT_MODS_FOLDER): null,
  _enum_key_to_str(Config.Key.ESP_ESM_DEFAULT_ADD_MODE): AddMode.UNKNOWN,
  _enum_key_to_str(Config.Key.ESP_ESM_CHOICE_ADD_MOD_CONFLICT): AddModeConflict.SKIP,
  _enum_key_to_str(Config.Key.ESP_ESM_CHOICE_MOD_ACTIVATED_CONFLICT): ModActivatedConflict.DEACTIVATE,
  _enum_key_to_str(Config.Key.ESP_ESM_CHOICE_MOD_DEACTIVATED_CONFLICT): ModDeactivatedConflict.LEAVE,

  # UnrealPak
  _enum_key_to_str(Config.Key.SHOW_UNREAL_PAK): true,
  _enum_key_to_str(Config.Key.UNREAL_PAK_AVAILABLE_MODS_FOLDER): Global.get_manager_subpath("Available UnrealPak mods"),
  _enum_key_to_str(Config.Key.UNREAL_PAK_DEFAULT_MODS_FOLDER): null,
  _enum_key_to_str(Config.Key.UNREAL_PAK_DEFAULT_ADD_MODE): AddMode.UNKNOWN,
  _enum_key_to_str(Config.Key.UNREAL_PAK_CHOICE_ADD_MOD_CONFLICT): AddModeConflict.SKIP,
  _enum_key_to_str(Config.Key.UNREAL_PAK_CHOICE_MOD_ACTIVATED_CONFLICT): ModActivatedConflict.DEACTIVATE,
  _enum_key_to_str(Config.Key.UNREAL_PAK_CHOICE_REGULAR_MOD_DEACTIVATED_CONFLICT): ModDeactivatedConflict.MOVE_BACK,
  _enum_key_to_str(Config.Key.UNREAL_PAK_CHOICE_COPY_ON_ACTIVATION_MOD_DEACTIVATED_CONFLICT): ModDeactivatedConflict.MOVE_BACK,

  # OBSE
  _enum_key_to_str(Config.Key.SHOW_OBSE): true,
  _enum_key_to_str(Config.Key.OBSE_AVAILABLE_MODS_FOLDER): Global.get_manager_subpath("Available OBSE mods"),
  _enum_key_to_str(Config.Key.OBSE_DEFAULT_MODS_FOLDER): null,
  _enum_key_to_str(Config.Key.OBSE_DEFAULT_ADD_MODE): AddMode.UNKNOWN,
  _enum_key_to_str(Config.Key.OBSE_CHOICE_ADD_MOD_CONFLICT): AddModeConflict.SKIP,
  _enum_key_to_str(Config.Key.OBSE_CHOICE_MOD_ACTIVATED_CONFLICT): ModActivatedConflict.DEACTIVATE,
  _enum_key_to_str(Config.Key.OBSE_CHOICE_REGULAR_MOD_DEACTIVATED_CONFLICT): ModDeactivatedConflict.MOVE_BACK,
  _enum_key_to_str(Config.Key.OBSE_CHOICE_COPY_ON_ACTIVATION_MOD_DEACTIVATED_CONFLICT): ModDeactivatedConflict.MOVE_BACK,

  # UE4SS
  _enum_key_to_str(Config.Key.SHOW_UE4SS): true,
  _enum_key_to_str(Config.Key.UE4SS_DEFAULT_MODS_FOLDER): null,
  _enum_key_to_str(Config.Key.UE4SS_DEFAULT_ADD_MODE): AddMode.UNKNOWN,
  _enum_key_to_str(Config.Key.UE4SS_CHOICE_ADD_MOD_CONFLICT): AddModeConflict.SKIP,
  _enum_key_to_str(Config.Key.UE4SS_CHOICE_MOD_ACTIVATED_CONFLICT): ModActivatedConflict.DEACTIVATE,
  _enum_key_to_str(Config.Key.UE4SS_CHOICE_MOD_DEACTIVATED_CONFLICT): ModDeactivatedConflict.LEAVE,
}

func _write(data: Dictionary) -> void:
  data = Global.clear_unchanged_dict_keys(data, _DEFAULT)

  if data.is_empty():
    if FileSystem.is_file(_PATH): FileSystem.remove(_PATH)
  else:
    FileSystem.mkdir(FileSystem.get_directory(_PATH))
    FileSystem.write_json(_PATH, data)

func _read() -> Dictionary:
  if not FileSystem.exists(_PATH):
    return {}

  var data = FileSystem.read_json(_PATH)
  data = Global.clear_unchanged_dict_keys(data, _DEFAULT)
  return data

var _CACHE = null
func _cache() -> Dictionary:
  if _CACHE == null:
    _CACHE = _read()

  return _CACHE

func get_by_key(key: Config.Key):
  var key_str = _enum_key_to_str(key)

  var cache = _cache()
  if cache.has(key_str):
    return cache[key_str]
  return _DEFAULT[key_str]

func set_by_key(key: Config.Key, value, write: bool = true) -> void:
  var old_value = get_by_key(key)
  if old_value == value:
    return

  _CACHE[_enum_key_to_str(key)] = value
  if write: _write(_CACHE)
  setting_changed.emit(key, old_value, value, write)

func _generic_get_value_for_mod_type(mod_type: ModType.Value, default, base, mod_type_map: Dictionary, invalid_values: Array = [null]):
  if not mod_type_map.has(mod_type):
    Global.fatal_error(["Encountered unknown mod type '", mod_type, "' in Config::_generic_get_value_for_mod_type"])

  var value = get_by_key(mod_type_map[mod_type])
  if value not in invalid_values:
    return value

  value = get_by_key(base)
  if value not in invalid_values:
    return value

  return default

func _enum_key_to_str(key: Config.Key) -> String:
  return Config.Key.find_key(key).to_lower()
