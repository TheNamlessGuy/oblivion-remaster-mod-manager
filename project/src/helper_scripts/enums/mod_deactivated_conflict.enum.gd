class_name ModDeactivatedConflict # What to do when a regular mod is deactivated, but there's a conflicting mod where the available mods lie? When deactivating a "Copy on activation" mod, but the original file no longer exists?

# For typing purposes
enum Value {
  UNKNOWN = -1,

  LEAVE = 0,
  COPY_BACK = 1,
  REMOVE = 2,
}

# For use
const UNKNOWN = ModDeactivatedConflict.Value.UNKNOWN
const LEAVE = ModDeactivatedConflict.Value.LEAVE
const MOVE_BACK = ModDeactivatedConflict.Value.COPY_BACK
const REMOVE = ModDeactivatedConflict.Value.REMOVE

const ALL = [
  LEAVE,
  MOVE_BACK,
  REMOVE,
]

const _ID_TITLE_MAP = {
  LEAVE: "Leave",
  MOVE_BACK: "Move back",
  REMOVE: "Remove",
}

const _ID_TOOLTIP_MAP = {
  LEAVE: "Leave the file(s) where they are.\n\nNOTE: For some mod types, this may mean that the mod isn't deactivated",
  MOVE_BACK: "Move the file(s) to where they should be",
  REMOVE: "Remove the file(s)",
}

static func id_to_title(id: ModDeactivatedConflict.Value) -> String:
  return _ID_TITLE_MAP[id]

static func id_to_tooltip(id: ModDeactivatedConflict.Value) -> String:
  return _ID_TOOLTIP_MAP[id]
