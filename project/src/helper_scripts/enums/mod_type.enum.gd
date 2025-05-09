class_name ModType # This should always be 1:1 compatible with the Tab enum

# For typing purposes
enum Value {
  UNKNOWN = -1,

  ESP_ESM = Tab.ESP_ESM,
  UNREAL_PAK = Tab.UNREAL_PAK,
  OBSE = Tab.OBSE,
  UE4SS = Tab.UE4SS,
}

# For use
const UNKNOWN = ModType.Value.UNKNOWN
const ESP_ESM = ModType.Value.ESP_ESM
const UNREAL_PAK = ModType.Value.UNREAL_PAK
const OBSE = ModType.Value.OBSE
const UE4SS = ModType.Value.UE4SS

const ALL = [
  ESP_ESM,
  UNREAL_PAK,
  OBSE,
  UE4SS,
]
