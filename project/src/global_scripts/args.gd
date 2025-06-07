extends Node

enum Flags {
  UNKNOWN = -1,

  HELP = 0,
  MANAGER_FOLDER = 1,
}

func is_specified(flag: Flags) -> bool: return _cache.has(flag)
func get_value(flag: Flags) -> Variant:
  if not is_specified(flag):
    return null

  return _cache[flag]

func get_manager_folder() -> Variant:
  var value: Variant = get_value(Flags.MANAGER_FOLDER)
  if value == null: return null
  return value[0]

## Format:
## {
##   "id": A value from the Flags enum
##   "flags": An array of string representing the command line flags
##   "value": Optional. If the flag is encountered, the value will be set to this
##   "parameters": Optional. A list of string descriptions of the parameters this flag accepts
##   "description": The description to show while printing the help text
## }
const _FLAGS: Array[Dictionary] = [
  {"id": Flags.HELP, "flags": ["--help", "-h"], "description": "Displays this text. Hello!"},
  {"id": Flags.MANAGER_FOLDER, "flags": ["--manager-folder"], "parameters": ["DIRECTORY"], "description": "Specifies where NORMM will save configs, logs, and such"}
]

var _cache := {}
var _errors := []

func _init() -> void:
  _errors = []
  _parse()
  _validate()

func _ready() -> void:
  if len(_errors) > 0:
    for error in _errors:
      Global.prints(error)
    Global.exit(1)
    return

  if is_specified(Flags.HELP):
    _print_helptext()
    Global.exit(0)
    return

func _parse() -> void:
  var args := OS.get_cmdline_user_args()
  var i := 0
  while i < len(args):
    var found := false
    for flag in _FLAGS:
      if args[i] not in flag["flags"]:
        continue
      found = true
      var matched_flag := args[i]

      if flag.has("value"):
        _cache[flag["id"]] = flag["value"]
      elif not flag.has("parameters"):
        _cache[flag["id"]] = true
      else: # flag.has("parameters")
        var params := []
        var count := len(flag["parameters"])
        for p in range(count):
          i += 1
          if i >= len(args):
            _error(["Missing argument '", flag["parameters"][p], "' for flag '", matched_flag, "'"])
            return
          params.push_back(args[i])
        _cache[flag["id"]] = params

      break

    if not found:
      _error(["Unknown argument '", args[i], "'"])
      return

    i += 1

func _validate() -> void:
  var manager_folder: Variant = get_manager_folder()
  if manager_folder != null and not (manager_folder as String).is_absolute_path():
    _error(["The --manager-folder directory has to be specified as absolute"])

func _print_helptext() -> void:
  var flags: Array[String] = []
  var longest := 0
  for flag in _FLAGS:
    var flags_str := ", ".join(flag["flags"])
    if flag.has("parameters"):
      for param in flag["parameters"]:
        flags_str += " <" + param + ">"

    var length := len(flags_str)
    if length > longest:
      longest = length

    flags.push_back(flags_str)

  prints("Flags:")
  for f in range(len(flags)):
    var flags_str := flags[f]
    var flag := _FLAGS[f]

    prints("   ", flags_str.rpad(longest, " "), "     ", flag["description"])

func _error(msg: Array) -> void:
  _errors.push_back(msg)
