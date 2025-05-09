@tool
class_name InstallDirectorySettingsFileSelector
extends SettingsFileSelector

func _check_for_errors() -> void:
  super._check_for_errors()

  var v = value()
  if v.length() == 0:
    return

  if not FileSystem.is_file(FileSystem.path([v, "OblivionRemastered.exe"])):
    _alert_container.error(["This directory isn't an Oblivion Remaster installation directory, as it doesn't contain 'OblivionRemastered.exe'"])

func _on_file_selected(file: String) -> void:
  _set_input_text(FileSystem.get_directory(file))
