@tool
class_name NotificationContainer
extends ScrollContainer

func empty() -> bool: return notification_count() == 0
func notification_count() -> int:
  return _container.get_child_count()

func add_notification(notif: BaseNotification) -> void:
  _container.add_child(notif)
  notif.dying.connect(_set_width)
  notif._start()

  _set_width()

static var MARGIN := 5
var _container := VBoxContainer.new()

func _init() -> void:
  horizontal_scroll_mode = SCROLL_MODE_DISABLED
  size_flags_horizontal = SIZE_SHRINK_END
  mouse_filter = Control.MOUSE_FILTER_IGNORE

  _container.size_flags_vertical = Control.SIZE_EXPAND
  _container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  add_child(_container)

func _set_width() -> void:
  custom_minimum_size.x = 0 if empty() else 200
