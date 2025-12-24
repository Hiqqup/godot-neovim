extends CodeEditInfo
const CodeEditInfo:= preload("res://addons/godot-neovim/code_edit_info.gd")
const MyScript:= preload("res://test/stubs/dont_change_this_script.gd")
static func get_current_code_edit()->CodeEdit:
	return CodeEdit.new();
static func get_current_script()->Script:
	return MyScript;
