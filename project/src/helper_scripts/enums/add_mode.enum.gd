class_name AddMode

# For typing purposes
enum Value {
  UNKNOWN = -1,

  MOVE_ON_ADD = 0,
  COPY_ON_ACTIVATION = 1,
}

# For use
const UNKNOWN := AddMode.Value.UNKNOWN
const MOVE_ON_ADD := AddMode.Value.MOVE_ON_ADD
const COPY_ON_ACTIVATION := AddMode.Value.COPY_ON_ACTIVATION

const _ID_TITLE_MAP := {
  MOVE_ON_ADD: "Move on add",
  COPY_ON_ACTIVATION: "Copy on activation",
}

const _ID_TOOLTIP_MAP := {
  MOVE_ON_ADD: "Moves the file(s) of the selected mod as soon as it's added",
  COPY_ON_ACTIVATION: "Copies the file(s) of the selected mod when it's activated (and saved)",
}

static func id_to_title(id: AddMode.Value) -> String:
  return _ID_TITLE_MAP[id]

static func id_to_tooltip(id: AddMode.Value) -> String:
  return _ID_TOOLTIP_MAP[id]
