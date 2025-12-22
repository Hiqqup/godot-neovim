const CodeEditInfo:= preload("res://addons/godot-neovim/code_edit_info.gd")
func setup():
	EditorInterface.get_script_editor().editor_script_changed.connect(
		func(script:Script): file_changed.emit(CodeEditInfo.get_file_path(script))
	)


signal gui_input(event: InputEvent)
signal file_changed(file_path: String)
signal caret_moved(pos: Vector2i)
