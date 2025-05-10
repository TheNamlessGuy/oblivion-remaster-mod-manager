class_name InstallDirectorySettingsFileSelector
extends SettingsFileSelector

func _setup_filters() -> void:
  _dialog.add_filter("OblivionRemastered.exe, gamelaunchhelper.exe", "The executable")

func _check_for_errors() -> void:
  super._check_for_errors()

  var v := value()
  if v.length() == 0:
    return

  if not Global.install_directory_is_valid(v):
    _alert_container.error(["This directory isn't an Oblivion Remaster installation directory, as it doesn't contain 'OblivionRemastered.exe' nor 'gamelaunchhelper.exe'"])

func _on_file_selected(file: String) -> void:
  _set_input_text(FileSystem.get_directory(file))
