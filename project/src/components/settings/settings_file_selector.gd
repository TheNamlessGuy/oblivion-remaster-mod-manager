class_name SettingsFileSelector
extends VBoxContainer

signal changed()

func value() -> String: return _input.text
func is_valid() -> bool: return not _alert_container.has_errors()
func is_dirty() -> bool: return value() != _config_value()
func save(write: bool = true) -> void:
  if is_dirty():
    Config.set_by_key(config_key, value(), write)

@export var config_key: Config.Key
@export var fail_if_path_doesnt_exist: bool = true

@export_group("Label")
@export var label_text: String
@export_multiline var label_tooltip: String

@export_group("Dialog")
@export var dialog_title: String = "Select a file"
@export var dialog_file_mode: FileDialog.FileMode = FileDialog.FILE_MODE_OPEN_FILE
@export var dialog_access: FileDialog.Access = FileDialog.ACCESS_FILESYSTEM
@export var default_open_dir: OS.SystemDir = OS.SystemDir.SYSTEM_DIR_DOWNLOADS
@export var dialog_filters: Array[String] = []
@export var dialog_filter_descriptions: Array[String] = []

@export_group("Internal")
@export var _label: Label
@export var _input: LineEdit
@export var _button: Button
@export var _dialog: FileDialog
@export var _alert_container: AlertContainer

func _ready() -> void:
  _label.text = label_text + ": "
  _label.tooltip_text = label_tooltip
  _label.mouse_filter = Control.MOUSE_FILTER_STOP

  _input.text_changed.connect(_on_input_change)
  _set_input_text(_config_value(), true)

  _dialog.title = dialog_title
  _dialog.file_mode = dialog_file_mode
  _dialog.access = dialog_access
  _setup_filters()
  _dialog.file_selected.connect(_on_file_selected)
  _dialog.dir_selected.connect(_on_dir_selected)

  _button.button_up.connect(_on_button_pressed)

func _setup_filters() -> void:
  for i in range(dialog_filters.size()):
    if i >= dialog_filter_descriptions.size():
      _dialog.add_filter(dialog_filters[i])
    else:
      _dialog.add_filter(dialog_filters[i], dialog_filter_descriptions[i])

func _config_value() -> String:
  var v: Variant = Config.get_by_key(config_key)
  if v == null:
    return ""
  return v

func _on_button_pressed() -> void:
  if FileSystem.is_dir(_input.text):
    _dialog.current_dir = _input.text
  elif FileSystem.is_file(_input.text):
    _dialog.current_file = _input.text
  else:
    _dialog.current_dir = OS.get_system_dir(default_open_dir)

  _dialog.popup_centered()

func _set_input_text(to: String, force_update: bool = false) -> void:
  if force_update or _input.text != to:
    _input.text = to
    _on_input_change(to)

func _on_input_change(_to: String) -> void:
  _check_for_errors()
  changed.emit()

func _on_file_selected(file: String) -> void: _set_input_text(file)
func _on_dir_selected(dir: String) -> void: _set_input_text(dir)

func _check_for_errors() -> void:
  _alert_container.clear()

  var v := value()
  if v.length() == 0:
    return

  if not FileSystem.exists(v):
    if fail_if_path_doesnt_exist:
      _alert_container.error(["This path doesn't exist"])
    else:
      _alert_container.warning(["This path doesn't exist"])
