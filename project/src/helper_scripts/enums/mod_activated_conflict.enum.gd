class_name ModActivatedConflict # What to do when a mod gets activated, but copying/moving the files over would replace some other file?

# For typing purposes
enum Value {
  UNKNOWN = -1,

  DEACTIVATE = 0,
  REPLACE = 1,
}

# For use
const UNKNOWN := ModActivatedConflict.Value.UNKNOWN
const DEACTIVATE := ModActivatedConflict.Value.DEACTIVATE
const REPLACE := ModActivatedConflict.Value.REPLACE

const ALL := [
  DEACTIVATE,
  REPLACE,
]

const _ID_TITLE_MAP := {
  DEACTIVATE: "Deactivate",
  REPLACE: "Replace",
}

const _ID_TOOLTIP_MAP := {
  DEACTIVATE: "Skips over activating the mod, and gives you a warning",
  REPLACE: "Replaces the existing file(s)",
}

static func id_to_title(id: ModActivatedConflict.Value) -> String:
  return _ID_TITLE_MAP[id]

static func id_to_tooltip(id: ModActivatedConflict.Value) -> String:
  return _ID_TOOLTIP_MAP[id]
