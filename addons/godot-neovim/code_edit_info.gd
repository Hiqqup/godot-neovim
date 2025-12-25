static func get_dimensions( code_edit: CodeEdit)->Vector2i:
	var code_dimensions:= code_edit.size
	if code_edit.minimap_draw:
		code_dimensions.x -= code_edit.minimap_width
	code_dimensions.x -= code_edit.get_total_gutter_width()
	var font :Font=code_edit.get_theme_font("font")
	var char_dimension: Vector2=font.get_char_size(32, code_edit.get_theme_font_size("font_size"))
	var terminal_dimensions := Vector2i( code_dimensions/char_dimension)
	return terminal_dimensions;

static func set_caret_pos(code_edit: CodeEdit, pos: Vector2i):
	code_edit.set_meta("moving_programmatically", true)
	code_edit.set_caret_line(pos.y)
	code_edit.set_caret_column(pos.x);

static func get_caret_pos(code_edit:CodeEdit)->Vector2i:
	var line := code_edit.get_caret_line() + 1 #might be specific to my config
	var col :=  code_edit.get_caret_column()
	return Vector2i(col, line)
static func get_file_path(script:Script)->String:
	var file_path:String = ProjectSettings.globalize_path(script.resource_path)
	return file_path;
static func get_current_code_edit()->CodeEdit:
	var script_editor := EditorInterface.get_script_editor();
	var _code_edit:= script_editor.get_current_editor().get_base_editor() as CodeEdit
	return _code_edit
static func get_current_script()->Script:
	var script_editor := EditorInterface.get_script_editor();
	return script_editor.get_current_script()
