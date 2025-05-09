class_name TabSettingsDropdown
extends SettingsDropdown

func save(write: bool = true) -> void: Config.set_by_key(config_key, Tab.id_to_settings_key(value()), write)

func _add_items() -> void:
  for id in Tab.ALL:
    _dropdown.add_item(Tab.id_to_title(id))

func _config_value() -> int:
  var v = Config.get_by_key(config_key)
  if v == null:
    return -1
  return Tab.settings_key_to_id(v)
