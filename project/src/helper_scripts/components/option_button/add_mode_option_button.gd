class_name AddModeOptionButton
extends OptionButton

func _ready() -> void:
  clear()

  add_item(AddMode.id_to_title(AddMode.MOVE_ON_ADD))
  set_item_tooltip(AddMode.MOVE_ON_ADD, AddMode.id_to_tooltip(AddMode.MOVE_ON_ADD))

  add_item(AddMode.id_to_title(AddMode.COPY_ON_ACTIVATION))
  set_item_tooltip(AddMode.COPY_ON_ACTIVATION, AddMode.id_to_tooltip(AddMode.COPY_ON_ACTIVATION))
