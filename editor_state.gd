class T:
	#TODO this cannot be just one there have to be one per text edit
	var _mode_label:Label = Label.new()
	static var singleton: T
	var current_code_edit: CodeEdit;
	var mode: String :
		set(val):
			_mode_label.text = val
			mode = val;
	func add_label_to_status_bar(status_bar: HBoxContainer):
		status_bar.add_child( _mode_label)
		status_bar.move_child(_mode_label, 2)
	func free_label():
		_mode_label.free()
class Util:
	static func set_cursor_mode():
		var code_edit := T.singleton.current_code_edit;
		var mode = T.singleton.mode
		if mode == 'insert':
			code_edit.caret_type = CodeEdit.CARET_TYPE_LINE
			code_edit.caret_blink = true;
		else:
			code_edit.caret_type = CodeEdit.CARET_TYPE_BLOCK
			code_edit.caret_blink = false;
