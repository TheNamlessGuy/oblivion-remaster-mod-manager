class_name AddModConflict # What to do when you're adding a mod, and a conflicting one already exists?

# For typing purposes
enum Value {
  UNKNOWN = -1,

  SKIP = 0,
  REPLACE = 1,
}

# For use
const UNKNOWN := AddModConflict.Value.UNKNOWN
const SKIP := AddModConflict.Value.SKIP
const REPLACE := AddModConflict.Value.REPLACE

const _ID_TITLE_MAP := {
  SKIP: "Skip",
  REPLACE: "Replace",
}

const _ID_TOOLTIP_MAP := {
  SKIP: "Skips over adding the file(s), and gives you a warning",
  REPLACE: "Replaces the existing file(s)",
}

static func id_to_title(id: AddModConflict.Value) -> String:
  return _ID_TITLE_MAP[id]

static func id_to_tooltip(id: AddModConflict.Value) -> String:
  return _ID_TOOLTIP_MAP[id]
