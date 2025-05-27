class_name InfoNotification
extends BaseTimedNotification

func set_text(to: String) -> void: _label.text = to

var _label := Label.new()

func _initialize() -> void:
  super._initialize()
  _label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _add_container_children() -> void:
  _container.add_child(_label)
