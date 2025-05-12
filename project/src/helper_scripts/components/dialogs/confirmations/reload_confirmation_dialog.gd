class_name ReloadConfirmationDialog
extends ConfirmDialog

func _initialize() -> void:
  super._initialize()

  title = "Reload?"
  _set_text(["This will undo any saved changes. Are you sure?"])
  get_confirm_button().text = "Yes, reload"
  get_cancel_button().text = "No, let me save first"
