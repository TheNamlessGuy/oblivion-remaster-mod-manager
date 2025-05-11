class_name SettingsDropdown
extends VBoxContainer

signal changed()

func value() -> int: return _dropdown.selected
func is_valid() -> bool: return not _alert_container.has_errors()
func is_dirty() -> bool: return value() != _config_value()
func reload() -> void: _set_dropdown_value(_config_value(), true)
func save(write: bool = true) -> void:
  if is_dirty():
    Config.set_by_key(config_key, value(), write)

@export var config_key: Config.Key = Config.Key.UNKNOWN

@export_group("Label")
@export var label_text: String = "Default text"
@export_multiline var label_tooltip: String

@export_group("Dropdown")
@export var values: Array[String]

@export_group("Internal")
@export var _label: Label
@export var _dropdown: OptionButton
@export var _alert_container: AlertContainer

func _ready() -> void:
  _label.text = label_text + ": "
  _label.tooltip_text = label_tooltip
  _label.mouse_filter = Control.MOUSE_FILTER_STOP

  _add_items()
  _set_dropdown_value(_config_value(), true)
  _dropdown.item_selected.connect(_on_dropdown_change)

func _add_items() -> void:
  for v in values:
    _dropdown.add_item(v)

func _config_value() -> int:
  var v: Variant = Config.get_by_key(config_key)
  if v == null:
    return -1
  return v

func _set_dropdown_value(to: int, force_update: bool = false) -> void:
  if force_update or _dropdown.selected != to:
    _dropdown.selected = to
    _on_dropdown_change(to)

func _on_dropdown_change(_to: int) -> void:
  _check_for_errors()
  changed.emit()

func _check_for_errors():
  _alert_container.clear()
