class_name MainWindow
extends Control

@export var save_button: Button
@export var tab_container: WindowTabContainer

func _ready() -> void:
  save_button.button_up.connect(_on_save_button_pressed)
  tab_container.tab_changed.connect(_on_tab_changed)

  _on_tab_changed(tab_container.current_tab)

func _on_save_button_pressed() -> void:
  tab_container.tab_node(tab_container.current_tab).save()

func _on_tab_changed(to: int) -> void:
  var from = tab_container.get_previous_tab()

  var from_node = tab_container.tab_node(from)
  if from_node.can_save_status_changed.is_connected(_can_save_status_changed):
    from_node.can_save_status_changed.disconnect(_can_save_status_changed)

  var to_node = tab_container.tab_node(to)
  to_node.can_save_status_changed.connect(_can_save_status_changed)
  _can_save_status_changed(to_node.can_save())

func _can_save_status_changed(to: bool) -> void:
  save_button.disabled = not to
