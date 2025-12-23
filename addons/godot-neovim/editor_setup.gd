const CodeEditInfo:=preload("res://addons/godot-neovim/code_edit_info.gd")

signal ui_attach_requested(dimensions:Vector2i)
signal open_current_file_requested(file_path:String, options: Dictionary[String, bool])
signal file_changed(file_path:String)
signal connection_establish_requested()
signal set_code_edit_requested()
func setup():
	var script_editor:= EditorInterface.get_script_editor()
	var code_edit:= script_editor.get_current_editor().get_base_editor() as CodeEdit
	var dimensions:= CodeEditInfo.get_dimensions(code_edit)
	var script:= script_editor.get_current_script();
	var script_path := CodeEditInfo.get_file_path(script)
	
	script_editor.editor_script_changed.connect(func(script:Script):
		file_changed.emit(CodeEditInfo.get_file_path(script)))
	set_code_edit_requested.emit();
	connection_establish_requested.emit();
	ui_attach_requested.emit(dimensions, {
		"ext_cmdline" = true
	});
	open_current_file_requested.emit(script_path)
