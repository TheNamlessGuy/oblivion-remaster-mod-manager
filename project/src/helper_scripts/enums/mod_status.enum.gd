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
const UNKNOWN := ModStatus.Value.UNKNOWN
const REGULAR := ModStatus.Value.REGULAR
const COPY_ON_ACTIVATION := ModStatus.Value.COPY_ON_ACTIVATION
const NOT_FOUND := ModStatus.Value.NOT_FOUND
const UNMANAGEABLE := ModStatus.Value.UNMANAGEABLE

static func id_to_tooltip(id: ModStatus.Value, files: Array) -> String:
  files.sort_custom(func(a: String, b: String) -> bool: return a.length() < b.length())
  var file_str := '\n* ' + '\n* '.join(files)#Global.remove_common_prefix(files)) # TODO

  if id == REGULAR:
    return "This mod contains the files:" + file_str
  elif id == COPY_ON_ACTIVATION:
    return "This is a 'Copy on activation' mod containing the files:" + file_str
  elif id == NOT_FOUND:
    return "This mod seemingly no longer exists"
  elif id == UNMANAGEABLE:
    return "This mod can't be managed by the mod manager.\n\nIt's probably been manually activated in a way the mod manager can't handle.\nManually uninstalling, then reinstalling using the manager should fix this."
  else:
    Global.fatal_error(["Unknown ID '", id, "' encountered"])
    return ""

static func id_to_color(id: ModStatus.Value, for_node: Control) -> Color:
  return ThemeManager.color({
    ModStatus.REGULAR: "mod_type__regular",
    ModStatus.COPY_ON_ACTIVATION: "mod_type__copy_on_activation",
    ModStatus.NOT_FOUND: "mod_type__not_found",
    ModStatus.UNMANAGEABLE: "mod_type__unmanageable",
  }[id], for_node)
