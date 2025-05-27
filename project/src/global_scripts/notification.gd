extends Node

func info(msg: Array, title: String = "Information", ttl: int = 5) -> void:
  var notif := InfoNotification.new()
  notif.set_title(title)
  notif.set_text(Global.array_to_string(msg))
  notif.ttl = ttl
  _container.add_notification(notif)

var _container: NotificationContainer = null
func _ready() -> void:
  _container = get_tree().get_current_scene().find_child("MarginContainer").find_child("NotificationContainer")
  assert(_container != null, "Couldn't find NotificationContainer")
