class_name BaseModSelector
extends BoxContainer

signal can_save_status_changed(to: bool)
signal dirty_status_changed(to: bool)

## Check whether there are unsaved changes
func is_dirty(_force_refresh: bool = false) -> bool:
  if not _force_refresh and _cached_dirty_status != null:
    return _cached_dirty_status
  return _do_is_dirty_check()

## Check whether we have any erroneous unsaved changes
func can_save(_force_refresh: bool = false) -> bool:
  if not _force_refresh and _cached_can_save_status != null:
    return _cached_can_save_status
  elif not is_dirty():
    return false
  else:
    return _do_can_save_check()

func save() -> void:
  alert_container.clear()
  _perform_save(_get_active_mod_diffs(), {
    ModDiffType.DEACTIVATED_REGULAR: ModDeactivatedConflict.UNKNOWN,
    ModDiffType.DEACTIVATED_COPY_ON_ACTIVATION: ModDeactivatedConflict.UNKNOWN,
    ModDiffType.DEACTIVATED_NOT_FOUND: ModDeactivatedConflict.UNKNOWN,

    ModDiffType.ACTIVATED_REGULAR: ModActivatedConflict.UNKNOWN,
    ModDiffType.ACTIVATED_COPY_ON_ACTIVATION: ModActivatedConflict.UNKNOWN,
    ModDiffType.ACTIVATED_NOT_FOUND: ModActivatedConflict.UNKNOWN,
  })

func reload() -> void:
  _load(true)

func disable(should_disable: bool = true) -> void:
  in_button.disabled = should_disable
  out_button.disabled = should_disable

  up_button.disabled = should_disable
  down_button.disabled = should_disable

  add_button.disabled = should_disable
  remove_button.disabled = should_disable
  add_mode_selector.disabled = should_disable

  var custom_buttons := custom_button_container.get_children()
  for child in custom_buttons:
    if child is Button:
      child.disabled = should_disable

  _custom_disabled_actions()

enum ModDiffType {
  DEACTIVATED_REGULAR            = 0,
  DEACTIVATED_COPY_ON_ACTIVATION = 1,
  DEACTIVATED_NOT_FOUND          = 2,

  ACTIVATED_REGULAR              = 3,
  ACTIVATED_COPY_ON_ACTIVATION   = 4,
  ACTIVATED_NOT_FOUND            = 5,
}

## What ModType this is. Set from editor
@export var mod_type: ModType.Value = ModType.UNKNOWN

@export_group("Nodes")
@export var alert_container: AlertContainer
@export var in_button: Button
@export var out_button: Button
@export var custom_button_container: HBoxContainer
@export var backup_restoration_file_dialog: FileDialog

@export_subgroup("Active mods")
@export var active_mods_list: ItemList
@export var up_button: Button
@export var down_button: Button

@export_subgroup("Available mods")
@export var available_mods_list: ItemList
@export var add_button: Button
@export var remove_button: Button
@export var add_mode_selector: AddModeOptionButton
@export var add_file_dialog: FileDialog

func _ready() -> void:
  in_button.button_up.connect(_activate_selected_available_mods)
  out_button.button_up.connect(_deactivate_selected_active_mods)

  up_button.button_up.connect(_on_move_active_mods.bind(-1))
  down_button.button_up.connect(_on_move_active_mods.bind(1))

  add_button.button_up.connect(_open_add_available_mods_dialog)
  remove_button.button_up.connect(_delete_selected_available_mods)

  _setup_file_dialogs()

  visibility_changed.connect(_on_visibility_changed)
  _on_visibility_changed()

  _custom_setup()

## Called when the visibility state of the entire mod selector changes
func _on_visibility_changed() -> void:
  if is_visible_in_tree():
    _load()

var _loaded := false
## Initialize the state of the mod selector
func _load(force: bool = false) -> void:
  if _loaded and not force:
    return

  if not _prerequisites_met():
    disable(true)
    return

  disable(false)

  _loaded = true

  alert_container.clear()
  add_mode_selector.select(Config.get_default_add_mode_for_mod_type(mod_type))
  _populate_active()
  _populate_available()
  _check_dirty_status()
  _check_can_save_status()

func _prerequisites_met() -> bool:
  alert_container.clear()

  if not Game.install_directory_is_valid():
    alert_container.info(["The installation directory is not valid. Please go to the 'Settings' tab and set it, then come back and press 'Reload'"])

  _custom_prerequisites_checks()

  return alert_container.empty()

## Override in child classes as needed
func _custom_prerequisites_checks() -> void:
  pass

## Override in child classes as needed
func _custom_setup() -> void:
  pass

## Override in child classes as needed
func _custom_disabled_actions() -> void:
  pass

func _setup_file_dialogs() -> void:
  add_file_dialog.title = "Select the mods to add"
  add_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
  add_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
  add_file_dialog.files_selected.connect(_on_add_selected_files)

  backup_restoration_file_dialog.title = "Select the backup to restore"
  backup_restoration_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
  backup_restoration_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
  backup_restoration_file_dialog.file_selected.connect(_restore_active_from_backup_file)

## Move a mod from available to active
func _activate_mod(mod: String) -> void:
  var status := _get_available_mod_status(mod) if _available_mod_exists(mod, true) else _get_active_mod_status(mod)
  var tooltip := _get_mod_tooltip_in_list(mod, available_mods_list)
  _remove_mod_from_list(mod, available_mods_list)
  _add_mod_to_list(mod, status, active_mods_list, tooltip)

## Move all the selected mods in the available list to the active list
func _activate_selected_available_mods() -> void:
  var selected := available_mods_list.get_selected_items()
  if selected.size() == 0:
    return

  selected.reverse()
  for idx in selected:
    _activate_mod(available_mods_list.get_item_text(idx))

  # Unreverse the moved mods
  var offset := selected.size() - 1
  var last_idx := active_mods_list.item_count - 1
  while offset > 0:
    var new_idx := last_idx - offset
    active_mods_list.move_item(last_idx, new_idx)
    offset -= 1

  _check_dirty_status()
  _check_can_save_status()

## Move a mod from active to available
func _deactivate_mod(mod: String) -> void:
  var status := _get_active_mod_status(mod) if _active_mod_exists(mod, true) else _get_available_mod_status(mod)
  if status == ModStatus.UNMANAGEABLE:
    Global.fatal_error(["Tried to deactivate an undeactivatable mod (", mod, "). Probably missed calling set_item_selectable(...) properly"])

  var tooltip := _get_mod_tooltip_in_list(mod, active_mods_list)
  _remove_mod_from_list(mod, active_mods_list)
  _add_mod_to_list(mod, status, available_mods_list, tooltip)
  available_mods_list.sort_items_by_text()

## Move all the selected mods in the active list to the available list
func _deactivate_selected_active_mods() -> void:
  var selected := active_mods_list.get_selected_items()
  if selected.size() == 0:
    return

  selected.reverse()
  for idx in selected:
    _deactivate_mod(active_mods_list.get_item_text(idx))

  _check_dirty_status()
  _check_can_save_status()

## Creates and adds a custom button. Call in child classes' _custom_setup
func _add_custom_button(text: String) -> Button:
  var button := Button.new()
  button.text = text

  var split := ExpandedHSplitContainer.new()

  custom_button_container.add_child(button)
  custom_button_container.add_child(split)

  button.visibility_changed.connect(func() -> void: split.visible = button.visible)

  return button

func _get_active_mod_status(mod: String) -> ModStatus.Value:
  if _active_mod_is_unmanageable(mod):
    return ModStatus.UNMANAGEABLE

  if CopyOnActivationMods.mod_type_has(mod_type, mod):
    if _active_copy_on_activation_mod_is_not_found(mod):
      return ModStatus.NOT_FOUND
    return ModStatus.COPY_ON_ACTIVATION
  elif _active_mod_is_not_found(mod):
    return ModStatus.NOT_FOUND

  return ModStatus.REGULAR

func _get_available_mod_status(mod: String) -> ModStatus.Value:
  if CopyOnActivationMods.mod_type_has(mod_type, mod):
    if _available_copy_on_activation_mod_is_not_found(mod):
      return ModStatus.NOT_FOUND
    return ModStatus.COPY_ON_ACTIVATION
  elif _other_available_mod_is_not_found(mod):
    return ModStatus.NOT_FOUND

  return ModStatus.REGULAR

## Caches the persisted state of the active mod list
var _persisted_active_mod_cache: Array = []
func _populate_active() -> void:
  active_mods_list.clear()

  var mods := _read_active_mods_from_fs()
  for mod in mods:
    _add_mod_to_list(mod, _get_active_mod_status(mod), active_mods_list)

  _persisted_active_mod_cache = _mod_list_to_array(active_mods_list)

## Caches the persisted state of the available mod list. You cannot rely on the order of mods in this list
var _persisted_available_mod_cache: Array = []
func _populate_available() -> void:
  available_mods_list.clear()

  var mods := _read_available_mods_from_fs()
  for mod in mods:
    _add_available_mod(mod, false)

  _persisted_available_mod_cache = _mod_list_to_array(available_mods_list)

func _add_available_mod(mod: String, add_to_persisted_cache: bool) -> void:
  _add_mod_to_list(mod, _get_available_mod_status(mod), available_mods_list)
  available_mods_list.sort_items_by_text()

  if add_to_persisted_cache:
    _persisted_available_mod_cache.push_back(mod)

func _delete_available_mod(mod: String) -> void:
  if mod.length() == 0:
    Global.fatal_error(["Tried to delete available mod with empty name - this is bad"])

  var status := _get_available_mod_status(mod)
  if status == ModStatus.REGULAR:
    _on_regular_mod_deletion(mod)
  elif status == ModStatus.COPY_ON_ACTIVATION:
    _on_copy_on_activation_mod_deletion(mod)
  elif status == ModStatus.NOT_FOUND:
    _on_not_found_mod_deletion(mod)
  else:
    Global.fatal_error(["Unknown status '", status, "' encountered in BaseModSelector::_delete_available_mod"])

  _remove_mod_from_list(mod, available_mods_list)

## Opens add_file_dialog
func _open_add_available_mods_dialog() -> void:
  alert_container.clear()

  var folder := Config.get_default_mods_folder_for_mod_type(mod_type)
  if folder != null and folder.length() > 0 and FileSystem.is_dir(folder):
    add_file_dialog.current_dir = folder
  else:
    add_file_dialog.current_dir = ""

  add_file_dialog.popup_centered()

func _open_backup_restoration_file_dialog() -> void:
  alert_container.clear()
  backup_restoration_file_dialog.current_dir = Config.get_default_backups_folder_for_mod_type(mod_type)
  backup_restoration_file_dialog.popup_centered()

func _backup_active_list_to_file(file_prefix: String) -> void:
  var filename := file_prefix + "." + Global.current_timestamp_to_filename() + ".txt"
  var file := FileSystem.path([Config.get_default_backups_folder_for_mod_type(mod_type), filename])
  FileSystem.write_lines(file, _mod_list_to_array(active_mods_list), true)
  Notification.info(["Backup '", filename, "' created"])

## Called when a ModStatus.REGULAR mod is deleted.
## Override in child classes as needed
func _on_regular_mod_deletion(mod: String) -> void:
  _fs_trash_mod_files(mod, _get_available_paths_for_mod(mod, ModStatus.REGULAR))

## Called when a ModStatus.COPY_ON_ACTIVATION mod is deleted.
func _on_copy_on_activation_mod_deletion(mod: String) -> void:
  CopyOnActivationMods.remove_for_mod_type(mod_type, mod)

## Called when a ModStatus.NOT_FOUND mod is deleted
func _on_not_found_mod_deletion(mod: String) -> void:
  if CopyOnActivationMods.mod_type_has(mod_type, mod):
    _on_copy_on_activation_mod_deletion(mod)

## Deletes all the selected mods in the available list
func _delete_selected_available_mods() -> void:
  alert_container.clear()

  var selected := available_mods_list.get_selected_items()
  if selected.size() == 0:
    return

  selected.reverse()
  for idx in selected:
    _delete_available_mod(available_mods_list.get_item_text(idx))

  _check_dirty_status()
  _check_can_save_status()

## Read the active mods from the file system.
## Override in child classes
func _read_active_mods_from_fs() -> Array:
  Global.fatal_error([get_name(), " has not overloaded BaseModSelector::_read_active_mods_from_fs"])
  return []

## Read the available non-ModStatus.COPY_ON_ACTIVATION mods from the file system.
## Override in child classes
func _read_other_available_mods_from_fs() -> Array:
  Global.fatal_error([get_name(), " has not overloaded BaseModSelector::_read_other_available_mods_from_fs"])
  return []

## Read the available ModStatus.COPY_ON_ACTIVATION mods from the file system.
func _read_available_copy_on_activation_mods_from_fs() -> Array:
  var active_mods := _mod_list_to_array(active_mods_list)
  var other_mods := _read_other_available_mods_from_fs()
  return CopyOnActivationMods.get_mods_for_mod_type(mod_type).filter(func (mod: String) -> bool:
    return mod not in other_mods and not mod in active_mods
  )

## Reads all the available mods from the file system
func _read_available_mods_from_fs() -> Array:
  return _read_other_available_mods_from_fs() + _read_available_copy_on_activation_mods_from_fs()

## Check whether the given mod exists, if it were active
func _active_mod_exists(mod: String, persisted: bool) -> bool:
  if persisted:
    return mod in _persisted_active_mod_cache
  return mod in _mod_list_to_array(active_mods_list)

## Check whether the given mods exist, if it were available
func _available_mod_exists(mod: String, persisted: bool) -> bool:
  if persisted:
    return mod in _persisted_available_mod_cache
  return mod in _mod_list_to_array(available_mods_list)

## Perform the actual "is dirty" check
func _do_is_dirty_check() -> bool:
  return Global.arrays_diff(_persisted_active_mod_cache, _mod_list_to_array(active_mods_list))

## Perform the actual "can save" check
func _do_can_save_check() -> bool:
  return true

## Should return all the existing active paths that relate exclusively to the given mod.
## Override in child classes
func _get_active_paths_for_mod(_mod: String) -> Array:
  Global.fatal_error([get_name(), " has not overloaded BaseModSelector::_get_active_paths_for_mod"])
  return []

## Should return the paths that the active files of the mod would have were it to be deactivated.
## Override in child classes
func _convert_active_paths_to_available(_mod: String, _active_paths: Array, _status: ModStatus.Value) -> Array:
  Global.fatal_error([get_name(), " has not overloaded BaseModSelector::_convert_active_paths_to_available"])
  return []

## Should return all the existing available paths that relate exclusively to the given mod.
## Override in child classes
func _get_available_paths_for_mod(_mod: String, _status: ModStatus.Value) -> Array:
  Global.fatal_error([get_name(), " has not overloaded BaseModSelector::_get_available_paths_for_mod"])
  return []

## Should return the paths that the active files of the mod would have were it to be deactivated.
## Override in child classes
func _convert_available_paths_to_active(_mod: String, _available_paths: Array, _status: ModStatus.Value) -> Array:
  Global.fatal_error([get_name(), " has not overloaded BaseModSelector::_convert_available_paths_to_active"])
  return []

# START: Save section

func _perform_save(diffs: Dictionary, remembered_choices: Dictionary) -> void:
  if (diffs["removed"] as Array).is_empty() and (diffs["added"] as Array).is_empty():
    # Saving is finished
    _custom_post_save_actions()

    _populate_active()
    _populate_available()
    _check_dirty_status()
    _check_can_save_status()

    return

  while not (diffs["removed"] as Array).is_empty():
    var mod: String = (diffs["removed"] as Array).pop_front()
    var status := _get_active_mod_status(mod)
    var should_stop := false
    if status == ModStatus.REGULAR:
      should_stop = _perform_save_on_deactivated_regular_mod(mod, diffs, remembered_choices)
    elif status == ModStatus.COPY_ON_ACTIVATION:
      should_stop = _perform_save_on_deactivated_copy_on_activation_mod(mod, diffs, remembered_choices)
    elif status == ModStatus.NOT_FOUND:
      should_stop = _perform_save_on_deactivated_not_found_mod(mod, diffs, remembered_choices)
    elif status == ModStatus.UNMANAGEABLE:
      Global.fatal_error(["Tried to save deactivation of an undeactivatable mod (", mod, "). Probably missed calling set_item_selectable(...) properly"])
    else:
      Global.fatal_error(["Encountered unknown status '", status, "' while handling deactivated mods in BaseModSelector::_perform_save"])

    if should_stop:
      return

  while not (diffs["added"] as Array).is_empty():
    var mod: String = (diffs["added"] as Array).pop_front()
    var status := _get_available_mod_status(mod)
    var should_stop := false
    if status == ModStatus.REGULAR:
      should_stop = _perform_save_on_activated_regular_mod(mod, diffs, remembered_choices)
    elif status == ModStatus.COPY_ON_ACTIVATION:
      should_stop = _perform_save_on_activated_copy_on_activation_mod(mod, diffs, remembered_choices)
    elif status == ModStatus.NOT_FOUND:
      should_stop = _perform_save_on_activated_not_found_mod(mod, diffs, remembered_choices)
    elif status == ModStatus.UNMANAGEABLE:
      Global.fatal_error(["Tried to save activation of an undeactivatable mod (", mod, "). Probably missed calling set_item_selectable(...) properly"])
    else:
      Global.fatal_error(["Encountered unknown status '", status, "' while handling activated mods in BaseModSelector::_perform_save"])

    if should_stop:
      return

  _perform_save(diffs, remembered_choices) # This should end up in the "Saving is finished" if-statement at the top

func _on_save_conflict_prompt_response(action: int, remember: bool, remember_key: ModDiffType, callable: Callable, diffs: Dictionary, remembered_choices: Dictionary) -> void:
  if remember:
    remembered_choices[remember_key] = action

  callable.call(action)
  _perform_save(diffs, remembered_choices)

## Should return whether or not to stop processing the save
func _perform_save_on_deactivated_regular_mod(mod: String, diffs: Dictionary, remembered_choices: Dictionary) -> bool:
  var from := _get_active_paths_for_mod(mod)
  var to := _convert_active_paths_to_available(mod, from, ModStatus.REGULAR)

  var differing_paths := from.filter(func(from_path: String) -> bool: return from_path not in to)
  if differing_paths.size() == 0:
    return false # From and to paths are the same - don't do anything
  elif differing_paths.size() != from.size():
    Global.fatal_error(["Tried to perform deactivation on regular '", mod, "', but there were a weird number of differing paths.\nFrom:\n", "\n".join(from), "\nTo:\n", "\n".join(to)])

  var save_type := ModDiffType.DEACTIVATED_REGULAR
  var remembered_choice: ModDeactivatedConflict.Value = remembered_choices[save_type]
  var callback := _resolve_deactivated_regular_mod_file_conflict.bind(mod, from, to)

  var existing_to_files := to.filter(func(to_path: String) -> bool: return FileSystem.exists(to_path))
  if existing_to_files.size() == 0:
    _fs_move_mod_files(mod, from, to)
    return false
  elif remembered_choice != ModDeactivatedConflict.UNKNOWN:
    callback.call(remembered_choice)
    return false

  var prompt := ModDeactivatedConflictChoiceDialog.new()
  prompt.for_mod(ModStatus.REGULAR, mod, existing_to_files)
  prompt.choice_made.connect(_on_save_conflict_prompt_response.bind(save_type, callback, diffs, remembered_choices))
  prompt.open(self)
  return true

func _resolve_deactivated_regular_mod_file_conflict(action: ModDeactivatedConflict.Value, mod: String, from: Array, to: Array) -> void:
  if action == ModDeactivatedConflict.LEAVE:
    pass # Don't do anything
  elif action == ModDeactivatedConflict.MOVE_BACK:
    _fs_trash_mod_files(mod, to)
    _fs_move_mod_files(mod, from, to)
  elif action == ModDeactivatedConflict.REMOVE:
    _fs_trash_mod_files(mod, from)
  else:
    Global.fatal_error(["Encountered unknown ModDeactivatedConflict '", action, "' in BaseModSelector::_resolve_deactivated_regular_mod_file_conflict"])

## Should return whether or not to stop processing the save
func _perform_save_on_deactivated_copy_on_activation_mod(mod: String, diffs: Dictionary, remembered_choices: Dictionary) -> bool:
  var from := _get_active_paths_for_mod(mod)
  var to := _convert_active_paths_to_available(mod, from, ModStatus.COPY_ON_ACTIVATION)

  var differing_paths := from.filter(func(from_path: String) -> bool: return from_path not in to)
  if differing_paths.size() == 0:
    return false # From and to paths are the same - don't do anything
  elif differing_paths.size() != from.size():
    Global.fatal_error(["Tried to perform deactivation on copy on activation '", mod, "', but there were a weird number of differing paths.\nFrom:\n", "\n".join(from), "\nTo:\n", "\n".join(to)])

  var save_type := ModDiffType.DEACTIVATED_COPY_ON_ACTIVATION
  var remembered_choice: ModDeactivatedConflict.Value = remembered_choices[save_type]
  var callback := _resolve_deactivated_copy_on_activation_mod_file_conflict.bind(mod, from, to)

  var nonexistant_to_files := to.filter(func(to_path: String) -> bool: return not FileSystem.exists(to_path))
  if nonexistant_to_files.size() == 0: # No conflict
    _fs_trash_mod_files(mod, from)
    return false
  elif remembered_choice != ModDeactivatedConflict.UNKNOWN:
    callback.call(remembered_choice)
    return false

  var prompt := ModDeactivatedConflictChoiceDialog.new()
  prompt.for_mod(ModStatus.COPY_ON_ACTIVATION, mod, nonexistant_to_files)
  prompt.choice_made.connect(_on_save_conflict_prompt_response.bind(save_type, callback, diffs, remembered_choices))
  prompt.open(self)
  return true

func _resolve_deactivated_copy_on_activation_mod_file_conflict(action: ModDeactivatedConflict.Value, mod: String, from: Array, to: Array) -> void:
  if action == ModDeactivatedConflict.LEAVE:
    pass # Don't do anything
  elif action == ModDeactivatedConflict.MOVE_BACK:
    _fs_trash_mod_files(mod, to)
    _fs_move_mod_files(mod, from, to)
  elif action == ModDeactivatedConflict.REMOVE:
    _fs_trash_mod_files(mod, from)
  else:
    Global.fatal_error(["Encountered unknown ModDeactivatedConflict '", action, "' in BaseModSelector::_resolve_deactivated_copy_on_activation_mod_file_conflict"])

## Should return whether or not to stop processing the save.
func _perform_save_on_deactivated_not_found_mod(_mod: String, _diffs: Dictionary, _remembered_choices: Dictionary) -> bool:
  return false # Noop

## Should return whether or not to stop processing the save
func _perform_save_on_activated_regular_mod(mod: String, diffs: Dictionary, remembered_choices: Dictionary) -> bool:
  var from := _get_available_paths_for_mod(mod, ModStatus.REGULAR)
  var to := _convert_available_paths_to_active(mod, from, ModStatus.REGULAR)

  var differing_paths := from.filter(func(from_path: String) -> bool: return from_path not in to)
  if differing_paths.size() == 0:
    return false # From and to paths are the same - don't do anything
  elif differing_paths.size() != from.size():
    Global.fatal_error(["Tried to perform activation on regular mod '", mod, "', but there were a weird number of differing paths.\nFrom:\n", ", ".join(from), "\nTo:\n", ", ".join(to)])

  var save_type := ModDiffType.ACTIVATED_REGULAR
  var remembered_choice: ModActivatedConflict.Value = remembered_choices[save_type]
  var callback := _resolve_activated_regular_mod_file_conflict.bind(mod, from, to)

  var existing_to_files := to.filter(func(to_path: String) -> bool: return FileSystem.exists(to_path))
  if existing_to_files.size() == 0: # No conflict
    _fs_move_mod_files(mod, from, to)
    return false
  elif remembered_choice != ModActivatedConflict.UNKNOWN:
    callback.call(remembered_choice)
    return false

  var prompt := ModActivatedConflictChoiceDialog.new()
  prompt.for_mod(ModStatus.REGULAR, mod, existing_to_files)
  prompt.choice_made.connect(_on_save_conflict_prompt_response.bind(save_type, callback, diffs, remembered_choices))
  prompt.open(self)
  return true

func _resolve_activated_regular_mod_file_conflict(action: ModActivatedConflict.Value, mod: String, from: Array, to: Array) -> void:
  if action == ModActivatedConflict.DEACTIVATE:
    pass # Don't do anything
  elif action == ModActivatedConflict.REPLACE:
    _fs_trash_mod_files(mod, to)
    _fs_move_mod_files(mod, from, to)
  else:
    Global.fatal_error(["Encountered unknown ModActivatedConflict '", action, "' in BaseModSelector::_resolve_activated_regular_mod_file_conflict"])

## Should return whether or not to stop processing the save.
func _perform_save_on_activated_copy_on_activation_mod(mod: String, diffs: Dictionary, remembered_choices: Dictionary) -> bool:
  var from := _get_available_paths_for_mod(mod, ModStatus.COPY_ON_ACTIVATION)
  var to := _convert_available_paths_to_active(mod, from, ModStatus.COPY_ON_ACTIVATION)

  var differing_paths := from.filter(func(from_path: String) -> bool: return from_path not in to)
  if differing_paths.size() == 0:
    return false # From and to paths are the same - don't do anything
  elif differing_paths.size() != from.size():
    Global.fatal_error(["Tried to perform activation on copy on activation mod '", mod, "', but there were a weird number of differing paths.\nFrom:\n", ", ".join(from), "\nTo:\n", ", ".join(to)])

  var save_type := ModDiffType.ACTIVATED_COPY_ON_ACTIVATION
  var remembered_choice: ModActivatedConflict.Value = remembered_choices[save_type]
  var callback := _resolve_activated_copy_on_activation_mod_file_conflict.bind(mod, from, to)

  var existing_to_files := to.filter(func(to_path: String) -> bool: return FileSystem.exists(to_path))
  if existing_to_files.size() == 0: # No conflict
    _fs_copy_mod_files(mod, from, to)
    return false
  elif remembered_choice != ModActivatedConflict.UNKNOWN:
    callback.call(remembered_choice)
    return false

  var prompt := ModActivatedConflictChoiceDialog.new()
  prompt.for_mod(ModStatus.COPY_ON_ACTIVATION, mod, existing_to_files)
  prompt.choice_made.connect(_on_save_conflict_prompt_response.bind(save_type, callback, diffs, remembered_choices))
  prompt.open(self)
  return true

func _resolve_activated_copy_on_activation_mod_file_conflict(action: ModActivatedConflict.Value, mod: String, from: Array, to: Array) -> void:
  if action == ModActivatedConflict.DEACTIVATE:
    pass # Don't do anything
  elif action == ModActivatedConflict.REPLACE:
    _fs_trash_mod_files(mod, to)
    _fs_copy_mod_files(mod, from, to)
  else:
    Global.fatal_error(["Encountered unknown ModActivatedConflict '", action, "' in BaseModSelector::_resolve_activated_copy_on_activation_mod_file_conflict"])

## Should return whether or not to stop processing the save
func _perform_save_on_activated_not_found_mod(_mod: String, _diffs: Dictionary, _remembered_choices: Dictionary) -> bool:
  return false # Noop

## Override in child classes as needed
func _custom_post_save_actions() -> void:
  pass

# END: Save section

# START: FileSystem section

func _fs_copy_mod_files(mod: String, from: Array, to: Array) -> void:
  if from.size() != to.size():
    Global.fatal_error(["Tried to copy the files of mod '", mod, "', but the from and to arrays diffed in length.\nFrom:\n", ", ".join(from), "\nTo:\n", ", ".join(to)])

  var zipped_files := Global.zip_arrays(from, to)
  from.sort_custom(FileSystem.sort_deepest_first)

  for i in range(from.size()):
    var from_path: String = from[i]
    var to_path: String = zipped_files[from_path]

    if FileSystem.is_dir(from_path):
      continue # No need to copy a directory. If there are files in it, the 'to' directory will be created when the files are copied

    FileSystem.copy(from_path, to_path, true)

func _fs_move_mod_files(mod: String, from: Array, to: Array) -> void:
  if from.size() != to.size():
    Global.fatal_error(["Tried to move the files of mod '", mod, "', but the from and to arrays diffed in length.\nFrom:\n", ", ".join(from), "\nTo:\n", ", ".join(to)])

  var zipped_files := Global.zip_arrays(from, to)
  from.sort_custom(FileSystem.sort_deepest_first)

  for i in range(from.size()):
    var from_path: String = from[i]
    var to_path: String = zipped_files[from_path]

    if FileSystem.is_dir(from_path):
      var from_empty = FileSystem.dir_is_empty(from_path)
      if FileSystem.is_dir(to_path):
        if from_empty:
          FileSystem.trash(from_path)
          continue
        else:
          continue # Do nothing
      elif from_empty:
        pass # Do the move
      else: # The mod doesn't own all the files in from_path, and to_path doesn't exist. Pretend we moved the directory without actually moving it
        FileSystem.ensure_dir_exists(to_path)
        continue

    FileSystem.move(from_path, to_path, true)

func _fs_trash_mod_files(_mod: String, files: Array) -> void:
  files = files.duplicate()
  files.sort_custom(FileSystem.sort_deepest_first)

  for file in files:
    if FileSystem.is_dir(file) and not FileSystem.dir_is_empty(file):
      continue # Mod doesn't own all files in the folder

    FileSystem.trash(file)

# END: FileSystem section

## Check whether the given mod would have ModStatus.NOT_FOUND, if it were active.
## Override in child classes as needed
func _active_mod_is_not_found(mod: String) -> bool:
  var files := _get_active_paths_for_mod(mod)
  for file in files:
    if not FileSystem.exists(file):
      return true

  return files.size() == 0

## Check whether the given mod would have ModStatus.NOT_FOUND, if it were an available non-ModStatus.COPY_ON_ACTIVATION mod.
## Override in child classes
func _other_available_mod_is_not_found(_mod: String) -> bool:
  Global.fatal_error([get_name(), " has not overloaded BaseModSelector::_other_available_mod_is_not_found"])
  return false

## Override in child classes
func _active_mod_is_unmanageable(_mod: String) -> bool:
  Global.fatal_error([get_name(), " has not overloaded BaseModSelector::_active_mod_is_unmanageable"])
  return false

## Check whether the given mod would have ModStatus.NOT_FOUND, if it were an active ModStatus.COPY_ON_ACTIVATION mod
func _active_copy_on_activation_mod_is_not_found(mod: String) -> bool:
  return _active_mod_is_not_found(mod)

## Check whether the given mod would have ModStatus.NOT_FOUND, if it were an available ModStatus.COPY_ON_ACTIVATION mod.
func _available_copy_on_activation_mod_is_not_found(mod: String) -> bool:
  return not CopyOnActivationMods.path_for_mod_exists(mod_type, mod)

## Override in child classes as needed. Is expected to show its own error message
func _attempted_added_mod_is_valid(_file: String) -> bool:
  return true

## Called when the user has selected some files in add_file_dialog
func _on_add_selected_files(packed_files: PackedStringArray) -> void:
  var files := []
  for packed_file in packed_files:
    if _attempted_added_mod_is_valid(packed_file):
      files.push_back(packed_file)

  _perform_mod_addition(files, AddModConflict.UNKNOWN)

func _perform_mod_addition(files: Array, remembered_choice: AddModConflict.Value) -> void:
  if files.size() == 0:
    # No more mods to add
    _check_dirty_status()
    _check_can_save_status()
    return

  var add_mode := add_mode_selector.selected

  while not files.is_empty():
    var file: String = files.pop_front()
    var mod := _get_mod_name_from_file(file)

    var exists_active := _active_mod_exists(mod, false)
    var exists_available := _available_mod_exists(mod, false)

    var callback := _resolve_mod_addition_conflict.bind(mod, file, add_mode, exists_active, exists_available)

    if not exists_active and not exists_available: # No conflict
      _persist_mod_file_addition(mod, file, add_mode)
      _add_available_mod(mod, true)
    elif remembered_choice != AddModConflict.UNKNOWN:
      callback.call(remembered_choice)
    else:
      var prompt := AddModConflictChoiceDialog.new()
      prompt.for_mod(mod)
      prompt.choice_made.connect(_on_add_conflict_prompt_response.bind(callback, files))
      prompt.open(self)
      return # Stop processing until the user choses an action

  _perform_mod_addition(files, remembered_choice)

func _resolve_mod_addition_conflict(action: AddModConflict.Value, mod: String, file: String, add_mode: AddMode.Value, exists_active: bool, exists_available: bool) -> void:
  if action == AddModConflict.SKIP:
    pass # Don't do anything
  elif action == AddModConflict.REPLACE:
    if exists_active:
      _deactivate_mod(mod)
      _delete_available_mod(mod)
      _persist_mod_file_addition(mod, file, add_mode)
      _add_available_mod(mod, true)
    elif exists_available:
      _delete_available_mod(mod)
      _persist_mod_file_addition(mod, file, add_mode)
      _add_available_mod(mod, true)
    else:
      Global.fatal_error(["BaseModSelector::_resolve_mod_addition_conflict ::: You're not supposed to get here"])
  else:
    Global.fatal_error(["Encountered unknown AddModConflict action '", action, "' in BaseModSelector::_resolve_mod_addition_conflict"])

func _on_add_conflict_prompt_response(action: AddModConflict.Value, remember: bool, callback: Callable, files: Array) -> void:
  callback.call(action)
  _perform_mod_addition(files, action if remember else AddModConflict.UNKNOWN)

## Given a mod file, return the name of the mod
## Override in child classes
func _get_mod_name_from_file(_file: String) -> String:
  Global.fatal_error([get_name(), " has not overloaded BaseModSelector::_get_mod_name_from_file"])
  return ""

## Called to persist a mod addition when the user has added some new mods. AddModConflict has already been considered when getting here.
## Override in child classes
func _persist_mod_file_addition(_mod: String, _file: String, _add_mode: AddMode.Value) -> void:
  Global.fatal_error([get_name(), " has not overloaded BaseModSelector::_persist_mod_file_addition"])

## Called when the user presses the up/down arrows on the active mod list
func _on_move_active_mods(offset: int) -> void:
  var selected := active_mods_list.get_selected_items()
  if selected.size() == 0:
    return

  if offset > 0:
    selected.reverse() # Otherwise the indexes get all messed up

  for idx in selected:
    active_mods_list.move_item(idx, idx + offset)

  _check_dirty_status()
  _check_can_save_status()

func _mod_list_to_array(list: ItemList) -> Array:
  var retval := []
  for i in range(list.item_count):
    retval.push_back(list.get_item_text(i))
  return retval

func _add_mod_to_list(mod: String, status: ModStatus.Value, list: ItemList, tooltip_override: Variant = null) -> int:
  var idx := list.add_item(mod)
  _set_mod_status_in_list_by_idx(idx, status, list, mod, tooltip_override)
  return idx

func _set_mod_status_in_list_by_idx(idx: int, status: ModStatus.Value, list: ItemList, mod: String, tooltip_override: Variant = null) -> void:
  list.set_item_custom_fg_color(idx, ModStatus.id_to_color(status, self))
  list.set_item_selectable(idx, status != ModStatus.UNMANAGEABLE)

  if tooltip_override != null:
    list.set_item_tooltip(idx, tooltip_override)
  else:
    var files := _get_active_paths_for_mod(mod) if list == active_mods_list else _get_available_paths_for_mod(mod, status)
    list.set_item_tooltip(idx, ModStatus.id_to_tooltip(status, files))

func _get_mod_idx_in_list(mod: String, list: ItemList) -> int:
  for i in range(list.item_count):
    if list.get_item_text(i) == mod:
      return i

  return -1

func _get_mod_tooltip_in_list(mod: String, list: ItemList) -> String:
  return list.get_item_tooltip(_get_mod_idx_in_list(mod, list))

func _remove_mod_from_list(mod: String, list: ItemList) -> void:
  list.remove_item(_get_mod_idx_in_list(mod, list))

## Returns what changes have been made to the active mod list since the last save in the format {"added": ["mod_name", ...], "removed": [...]}
func _get_active_mod_diffs() -> Dictionary:
  var active_mods := _mod_list_to_array(active_mods_list)
  return {
    "added": Global.diff_arrays(active_mods, _persisted_active_mod_cache),
    "removed": Global.diff_arrays(_persisted_active_mod_cache, active_mods)
  }

func _restore_active_from_backup_file(file: String) -> void:
  var restored_state := FileSystem.read_lines(file).filter(func(mod: String) -> bool: return mod.length() > 0)
  var active_mods := _mod_list_to_array(active_mods_list).filter(func(mod: String) -> bool: return mod.length() > 0)

  # Deactivate mods that shouldn't be active
  for mod in active_mods:
    if mod not in restored_state:
      _deactivate_mod(mod)

  # Activate available mods that should be active
  var i := 0
  while i < restored_state.size():
    var mod: String = restored_state[i]
    if _active_mod_exists(mod, false):
      i += 1
    elif _available_mod_exists(mod, false):
      i += 1
      _activate_mod(mod)
    else:
      alert_container.warning(["Couldn't restore mod '", mod, "', as it's not available"])
      restored_state.pop_at(i)

  # Set load order
  active_mods = _mod_list_to_array(active_mods_list)
  for ridx in range(restored_state.size()):
    var aidx := active_mods.find(restored_state[ridx])
    if ridx != aidx:
      active_mods_list.move_item(aidx, ridx)
      active_mods = _mod_list_to_array(active_mods_list)

  _check_dirty_status()
  _check_can_save_status()

var _cached_dirty_status: Variant = null
func _check_dirty_status() -> void:
  var dirty := is_dirty(true)
  if dirty != _cached_dirty_status:
    _cached_dirty_status = dirty
    dirty_status_changed.emit(dirty)

var _cached_can_save_status: Variant = null
func _check_can_save_status() -> void:
  var saveable := can_save(true)
  if saveable != _cached_can_save_status:
    _cached_can_save_status = saveable
    can_save_status_changed.emit(saveable)
