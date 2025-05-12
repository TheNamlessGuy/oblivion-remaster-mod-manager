extends Node

func add_for_mod_type(mod_type: ModType.Value, mod: String, path: String, write: bool = true) -> void:
  var key := _mod_type_to_key(mod_type)
  var cache := _cache()

  if not cache.has(key):
    cache[key] = {}
  elif cache[key][mod] == path:
    return # No need if it hasn't changed

  cache[key][mod] = path
  if write: _write(cache)

func get_all_for_mod_type(mod_type: ModType.Value) -> Dictionary:
  var key := _mod_type_to_key(mod_type)
  var cache := _cache()

  if cache.has(key):
    return cache[key].duplicate()
  return {}

func get_mods_for_mod_type(mod_type: ModType.Value) -> Array:
  return get_all_for_mod_type(mod_type).keys()

func get_path_for_mod(mod_type: ModType.Value, mod: String) -> String:
  return get_all_for_mod_type(mod_type)[mod]

func path_for_mod_exists(mod_type: ModType.Value, mod: String) -> bool:
  return FileSystem.exists(get_path_for_mod(mod_type, mod))

func remove_for_mod_type(mod_type: ModType.Value, mod: String, write: bool = true) -> void:
  var key := _mod_type_to_key(mod_type)
  var cache := _cache()

  if not cache.has(key) or not cache[key].has(mod):
    return # No need to do anything

  cache[key].erase(mod)
  if write: _write(cache)

func mod_type_has(mod_type: ModType.Value, mod: String) -> bool:
  var key := _mod_type_to_key(mod_type)
  var cache := _cache()

  return cache.has(key) and cache[key].has(mod)

var _PATH := Global.get_manager_subpath("copy-on-activation-mods.json")
var _DEFAULT: Dictionary = {
  _mod_type_to_key(ModType.ESP_ESM): {},
  _mod_type_to_key(ModType.UNREAL_PAK): {},
  _mod_type_to_key(ModType.OBSE): {},
  _mod_type_to_key(ModType.UE4SS): {},
  _mod_type_to_key(ModType.MAGIC_LOADER): {},
}

func _read() -> Dictionary:
  if not FileSystem.is_file(_PATH):
    return {}

  var data := FileSystem.read_json(_PATH)
  data = Global.clear_unchanged_dict_keys(data, _DEFAULT, true)
  return data

var _CACHE: Variant = null
func _cache() -> Dictionary:
  if _CACHE == null:
    _CACHE = _read()

  return _CACHE

func _write(data: Dictionary) -> void:
  data = Global.clear_unchanged_dict_keys(data, _DEFAULT, true)

  if data.is_empty():
    if FileSystem.is_file(_PATH): FileSystem.remove(_PATH)
  else:
    FileSystem.mkdir(FileSystem.get_directory(_PATH))
    FileSystem.write_json(_PATH, data)

func _mod_type_to_key(mod_type: ModType.Value) -> String:
  return {
    ModType.ESP_ESM: "esp_esm",
    ModType.UNREAL_PAK: "unreal_pak",
    ModType.OBSE: "obse",
    ModType.UE4SS: "ue4ss",
    ModType.MAGIC_LOADER: "magic_loader",
  }[mod_type]
