class_name SettingsTab
extends MarginContainer

signal can_save_status_changed(to: bool)
signal dirty_status_changed(to: bool)

func is_dirty(force_refresh: bool = false) -> bool:
  if not force_refresh and _cached_dirty_status != null:
    return _cached_dirty_status

  for node in _nodes:
    if node.is_dirty():
      return true

  return false

func can_save(force_refresh: bool = false) -> bool:
  if not force_refresh and _cached_can_save_status != null:
    return _cached_can_save_status
  elif not is_dirty():
    return false

  for node in _nodes:
    if not node.is_valid():
      return false

  return true

func save() -> void:
  if not is_dirty(true) or not can_save(true):
    return

  for node in _nodes:
    node.save(false)

  Config.flush()
  _check_statuses()

func _ready() -> void:
  _fill_nodes()

  for node in _nodes:
    node.changed.connect(_check_statuses)

  _check_statuses()

func _check_statuses() -> void:
  _check_dirty_status()
  _check_can_save_status()

var _nodes: Array[Node] = []
func _fill_nodes(parent: Node = self) -> void:
  for child in parent.get_children():
    if child is SettingsFileSelector or child is SettingsDropdown:
      _nodes.push_back(child)

    _fill_nodes(child)

var _cached_dirty_status = null
func _check_dirty_status() -> void:
  var dirty = is_dirty(true)
  if dirty != _cached_dirty_status:
    _cached_dirty_status = dirty
    dirty_status_changed.emit(dirty)

var _cached_can_save_status = null
func _check_can_save_status() -> void:
  var saveable = can_save(true)
  if saveable != _cached_can_save_status:
    _cached_can_save_status = saveable
    can_save_status_changed.emit(saveable)
