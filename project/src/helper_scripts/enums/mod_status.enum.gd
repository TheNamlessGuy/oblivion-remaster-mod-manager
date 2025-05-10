class_name ModStatus

# For typing purposes
enum Value {
  UNKNOWN = -1,

  REGULAR = 0,
  COPY_ON_ACTIVATION = 1,
  NOT_FOUND = 2,
  UNMANAGEABLE = 3,
}

# For use
const UNKNOWN = ModStatus.Value.UNKNOWN
const REGULAR = ModStatus.Value.REGULAR
const COPY_ON_ACTIVATION = ModStatus.Value.COPY_ON_ACTIVATION
const NOT_FOUND = ModStatus.Value.NOT_FOUND
const UNMANAGEABLE = ModStatus.Value.UNMANAGEABLE

const _ID_TOOLTIP_MAP = {
  REGULAR: "",
  COPY_ON_ACTIVATION: "This mod has been imported as 'Copy on activation'",
  NOT_FOUND: "This mod seemingly no longer exists",
  UNMANAGEABLE: "This mod can't be managed by the mod manager.\n\nIt's probably been manually activated in a way the mod manager can't handle.\nManually uninstalling, then reinstalling using the manager should fix this.",
}

const _ID_COLOR_MAP = {
  REGULAR: Color.WHITE,
  COPY_ON_ACTIVATION: Color.CYAN,
  NOT_FOUND: Color.RED,
  UNMANAGEABLE: Color.YELLOW,
}

static func id_to_tooltip(id: ModStatus.Value) -> String:
  return _ID_TOOLTIP_MAP[id]

static func id_to_color(id: ModStatus.Value, for_node: Control) -> Color:
  return ThemeManager.color({
    ModStatus.REGULAR: ThemeManager.MOD_TYPE__REGULAR,
    ModStatus.COPY_ON_ACTIVATION: ThemeManager.MOD_TYPE__COPY_ON_ACTIVATION,
    ModStatus.NOT_FOUND: ThemeManager.MOD_TYPE__NOT_FOUND,
    ModStatus.UNMANAGEABLE: ThemeManager.MOD_TYPE__UNMANAGEABLE,
  }[id], for_node)
