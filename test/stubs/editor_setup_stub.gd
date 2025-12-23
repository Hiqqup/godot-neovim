extends EditorSetup
const EditorSetup:=preload("res://addons/godot-neovim/editor_setup.gd")
func setup():
	set_code_edit_requested.emit(); # tgis is gonna cause problems
	connection_establish_requested.emit(); #tis is gonna cause problems
	ui_attach_requested.emit(Vector2i(0,0));
	open_current_file_requested.emit("")
	
