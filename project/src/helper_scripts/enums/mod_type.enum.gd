class_name ModType # This should always be 1:1 compatible with the Tab enum

# For typing purposes
enum Value {
  UNKNOWN = -1,

  ESP_ESM = Tab.ESP_ESM,
  UNREAL_PAK = Tab.UNREAL_PAK,
  OBSE = Tab.OBSE,
  UE4SS = Tab.UE4SS,
  MAGIC_LOADER = Tab.MAGIC_LOADER,
  TES_SYNC_MAP_INJECTOR = Tab.TES_SYNC_MAP_INJECTOR,
  NPC_APPEARANCE_MANAGER = Tab.NPC_APPEARANCE_MANAGER,
}

# For use
const UNKNOWN := ModType.Value.UNKNOWN
const ESP_ESM := ModType.Value.ESP_ESM
const UNREAL_PAK := ModType.Value.UNREAL_PAK
const OBSE := ModType.Value.OBSE
const UE4SS := ModType.Value.UE4SS
const MAGIC_LOADER := ModType.Value.MAGIC_LOADER
const TES_SYNC_MAP_INJECTOR := ModType.Value.TES_SYNC_MAP_INJECTOR
const NPC_APPEARANCE_MANAGER := ModType.Value.NPC_APPEARANCE_MANAGER

const ALL := [
  ESP_ESM,
  UNREAL_PAK,
  OBSE,
  UE4SS,
  MAGIC_LOADER,
  TES_SYNC_MAP_INJECTOR,
  NPC_APPEARANCE_MANAGER,
]
