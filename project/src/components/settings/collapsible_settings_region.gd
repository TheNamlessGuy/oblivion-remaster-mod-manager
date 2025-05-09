class_name CollapsibleSettingsRegion
extends VBoxContainer

@export var title: String = "Default text"
@export var collapsed_by_default: bool = false

@export_group("Internal")
@export var _header: Button
@export var _node_to_hide: Control
@export var _child_container: Control

@export_subgroup("Icons")
@export var _icon_collapsed: Texture2D
@export var _icon_uncollapsed: Texture2D

func _ready() -> void:
  _header.text = title
  _header.button_up.connect(_toggle_collapse)

  if collapsed_by_default:
    _collapse()
  else:
    _uncollapse()

  _move_children_into_child_container()

func _toggle_collapse() -> void:
  if _header.icon == _icon_collapsed:
    _uncollapse()
  else:
    _collapse()

func _collapse() -> void:
  _node_to_hide.visible = false
  _header.icon = _icon_collapsed

func _uncollapse() -> void:
  _node_to_hide.visible = true
  _header.icon = _icon_uncollapsed

func _move_children_into_child_container() -> void:
  var children: Array[Node] = get_children().filter(func(node: Node) -> bool: return node not in [_header, _node_to_hide, _child_container]) # TODO: Can we get the list of nodes that is hidden under the "Editable children" feature?
  for child in children:
    child.get_parent().remove_child(child)
    _child_container.add_child(child)
