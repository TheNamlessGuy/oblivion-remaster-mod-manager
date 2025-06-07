class_name Tab # This should always be 1:1 compatible with the ModType enum, for all the tabs that are mod type tabs

# For typing purposes
enum Value {
  UNKNOWN = -1,

  SETTINGS = 0,
  ESP_ESM = 1,
  MAGIC_LOADER = 2,
  NPC_APPEARANCE_MANAGER = 3,
  OBSE = 4,
  TES_SYNC_MAP_INJECTOR = 5,
  UE4SS = 6,
  UNREAL_PAK = 7,
}

# For use
const UNKNOWN := Value.UNKNOWN
const SETTINGS := Value.SETTINGS
const ESP_ESM := Value.ESP_ESM
const UNREAL_PAK := Value.UNREAL_PAK
const OBSE := Value.OBSE
const UE4SS := Value.UE4SS
const MAGIC_LOADER := Value.MAGIC_LOADER
const TES_SYNC_MAP_INJECTOR := Value.TES_SYNC_MAP_INJECTOR
const NPC_APPEARANCE_MANAGER := Value.NPC_APPEARANCE_MANAGER

const ALL := [
  SETTINGS,
  ESP_ESM,
  UNREAL_PAK,
  OBSE,
  UE4SS,
  MAGIC_LOADER,
  TES_SYNC_MAP_INJECTOR,
  NPC_APPEARANCE_MANAGER,
]

static func id_to_title(id: Tab.Value) -> String:
  return {
    SETTINGS: "Settings",
    ESP_ESM: "ESP/ESM",
    UNREAL_PAK: "UnrealPak",
    OBSE: "OBSE",
    UE4SS: "UE4SS",
    MAGIC_LOADER: "MagicLoader",
    TES_SYNC_MAP_INJECTOR: "TesSyncMapInjector",
    NPC_APPEARANCE_MANAGER: "NPCAppearanceManager",
  }[id]

const _ID_SETTINGS_KEY_MAP := {
    SETTINGS: "settings",
    ESP_ESM: "esp_esm",
    UNREAL_PAK: "unreal_pak",
    OBSE: "obse",
    UE4SS: "ue4ss",
    MAGIC_LOADER: "magic_loader",
    TES_SYNC_MAP_INJECTOR: "tes_sync_map_injector",
    NPC_APPEARANCE_MANAGER: "npc_appearance_manager",
  }

static func id_to_settings_key(id: Tab.Value) -> String:
  return _ID_SETTINGS_KEY_MAP[id]

static func settings_key_to_id(key: String) -> Tab.Value:
  return _ID_SETTINGS_KEY_MAP.find_key(key)
