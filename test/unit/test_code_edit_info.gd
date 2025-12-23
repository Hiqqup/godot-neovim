extends GutTest
const CodeEditInfo = preload("res://addons/godot-neovim/code_edit_info.gd")
var code_edit_stub: CodeEdit;
func before_all():
	code_edit_stub = CodeEdit.new();
	code_edit_stub.size = Vector2(200,200);
func after_all():
	code_edit_stub.free();

func test_get_dimensions():
	var dim = CodeEditInfo.get_dimensions(code_edit_stub);
	code_edit_stub.minimap_draw = true;
	var dim2 = CodeEditInfo.get_dimensions(code_edit_stub);
	assert_ne(dim, dim2);


	

#static func get_caret_pos(code_edit:CodeEdit)->Vector2i:
#	var line := code_edit.get_caret_line() + 1 #might be specific to my config
#	var col :=  code_edit.get_caret_column()
#	return Vector2i(col, line)
#static func get_file_path(script:Script)->String:
#	var file_path:String = ProjectSettings.globalize_path(script.resource_path)
#	return file_path;
#static func get_current_code_edit()->CodeEdit:
#	var script_editor := EditorInterface.get_script_editor();
#	var _code_edit:= script_editor.get_current_editor().get_base_editor() as CodeEdit
#	return _code_edit
