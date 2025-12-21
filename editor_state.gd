const ModeLabel:=preload("res://addons/godot-neovim/mode_label.gd")
static var global: CodeEditManager;
class CodeEditProperties:
	var caret_moves :=false
	var input_forwarded :=false
	var has_status:= false;
	var mode_label:= ModeLabel.T.new();
class CodeEditManager:
	var current: CodeEdit;
	var map: Dictionary[CodeEdit, CodeEditProperties]
	func get_properties(code_edit: CodeEdit) -> CodeEditProperties:
		if map.has(code_edit):
			return map[code_edit];
		map[code_edit] = CodeEditProperties.new();
		return map[code_edit];
	func get_current()->CodeEditProperties:
		return get_properties(current);
	var mode:String:
		get():
			return get_current().mode_label.text;
		set(val):
			get_current().mode_label.text = val;
	func clear_pointers():
		for code_edit in map.keys():
			var props:CodeEditProperties=map[code_edit]
			props.mode_label.queue_free();

static func set_cursor_mode():
	var code_edit := global.current;
	var mode = global.mode
	if mode == 'insert':
		code_edit.caret_type = CodeEdit.CARET_TYPE_LINE
		code_edit.caret_blink = true;
	else:
		code_edit.caret_type = CodeEdit.CARET_TYPE_BLOCK
		code_edit.caret_blink = false;
