class_name BaseTimedNotification
extends BaseNotification

var ttl := 5

var _timer := ProgressBar.new()

func _initialize() -> void:
  set_process(false)
  super._initialize()
  _timer.show_percentage = false
  _timer.min_value = 0
  _timer.value = 0

func _start() -> void:
  super._start()
  _timer.max_value = ttl
  _timer.value = _timer.max_value
  set_process(true)

func _process(delta: float) -> void:
  _timer.value -= delta
  if _timer.value <= 0:
    queue_free()
    dying.emit()

func _add_children_above_title(container: Control) -> void:
  super._add_children_above_title(container)
  container.add_child(_timer)
