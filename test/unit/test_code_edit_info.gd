extends GutTest
const CodeEditInfo = preload("res://addons/godot-neovim/code_edit_info.gd")
var code_edit_stub: CodeEdit;
func before_all():
	code_edit_stub = CodeEdit.new();
	code_edit_stub.size = Vector2(200,200);
	code_edit_stub.text = (CodeEditInfo as Script).source_code;
func after_all():
	code_edit_stub.free();

func test_get_dimensions():
	var dim = CodeEditInfo.get_dimensions(code_edit_stub);
	code_edit_stub.minimap_draw = true;
	var dim2 = CodeEditInfo.get_dimensions(code_edit_stub);
	assert_ne(dim, dim2);

func test_caret_pos():
	var pos1 = CodeEditInfo.get_caret_pos(code_edit_stub);
	CodeEditInfo.set_caret_pos(code_edit_stub, Vector2i(12,12));
	var pos2 = CodeEditInfo.get_caret_pos(code_edit_stub);
	assert_ne(pos1,pos2);

func test_get_file_path():
	var path = CodeEditInfo.get_file_path(CodeEditInfo as Script);
	assert_eq(path, ProjectSettings.globalize_path((CodeEditInfo as Script).resource_path));
