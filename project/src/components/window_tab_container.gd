class_name WindowTabContainer
extends TabContainer

func tab_node(id: Tab.Value) -> Control:
  return {
    Tab.SETTINGS: settings_node,
    Tab.ESP_ESM: esp_esm_node,
    Tab.UNREAL_PAK: unreal_pak_node,
    Tab.OBSE: obse_node,
    Tab.UE4SS: ue4ss_node,
    Tab.MAGIC_LOADER: magic_loader_node,
    Tab.TES_SYNC_MAP_INJECTOR: tes_sync_map_injector_node,
  }[id]

@export var settings_node: SettingsTab
@export var esp_esm_node: EspEsmModSelector
@export var unreal_pak_node: UnrealPakModSelector
@export var obse_node: OBSEModSelector
@export var ue4ss_node: UE4SSModSelector
@export var magic_loader_node: MagicLoaderModSelector
@export var tes_sync_map_injector_node: TesSyncMapInjectorModSelector

func _ready() -> void:
  Config.setting_changed.connect(_on_settings_changed)

  current_tab = Config.get_default_tab_id()
  for id in Tab.ALL:
    _set_title(id)
    tab_node(id).dirty_status_changed.connect(_on_dirty_status_changed.bind(id))
    set_tab_hidden(id, not Config.show_tab(id))

func _set_title(id: Tab.Value) -> void:
  var title := Tab.id_to_title(id)
  if tab_node(id).is_dirty():
    title += " (*)"
  set_tab_title(id, title)

func _on_dirty_status_changed(_to: bool, id: Tab.Value) -> void:
  _set_title(id)

func _on_settings_changed(key: Config.Key, _old_value, new_value, _persisted: bool) -> void:
  if key == Config.Key.SHOW_ESP_ESM:
    set_tab_hidden(Tab.ESP_ESM, not new_value)
  elif key == Config.Key.SHOW_UNREAL_PAK:
    set_tab_hidden(Tab.UNREAL_PAK, not new_value)
  elif key == Config.Key.SHOW_OBSE:
    set_tab_hidden(Tab.OBSE, not new_value)
  elif key == Config.Key.SHOW_UE4SS:
    set_tab_hidden(Tab.UE4SS, not new_value)
  elif key == Config.Key.SHOW_MAGIC_LOADER:
    set_tab_hidden(Tab.MAGIC_LOADER, not new_value)
  elif key == Config.Key.SHOW_TES_SYNC_MAP_INJECTOR:
    set_tab_hidden(Tab.TES_SYNC_MAP_INJECTOR, not new_value)
