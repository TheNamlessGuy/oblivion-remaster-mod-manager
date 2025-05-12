class_name ConfirmDialog
extends BaseChoiceDialog

signal confirmed()

func get_confirm_button() -> Button: return _confirm_button
func get_cancel_button() -> Button: return _cancel_button

var _confirm_button: Button
var _cancel_button: Button

func _initialize() -> void:
  super._initialize()

  _hide_close_button()

  _confirm_button = _add_button("OK")
  _confirm_button.button_up.connect(_on_confirmed)

  _cancel_button = _add_button("Cancel")
  _cancel_button.button_up.connect(_close)

func _on_confirmed() -> void:
  confirmed.emit()
  _close()
