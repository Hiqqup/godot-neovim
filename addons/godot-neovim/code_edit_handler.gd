# rename pending
const CodeEditInfoDependencyInjection:= preload("res://addons/godot-neovim/code_edit_info.gd")
const ModeLabel:= preload("res://addons/godot-neovim/mode_label.gd")
var CodeEditInfo :=CodeEditInfoDependencyInjection;
var code_edit: CodeEdit # this shall be the only refence to it
var mode_label:= ModeLabel.new();

signal caret_moved(pos: Vector2i);
signal gui_input(event: InputEvent);
var unset_meta:=func(_e): code_edit.set_meta("moving_programmatically", false)
func set_code_edit(_path:=""):
	remove_code_edit();
	code_edit = CodeEditInfo.get_current_code_edit();
	mode_label.add_to_status_bar(code_edit);
	code_edit.caret_changed.connect(caret_moved_emit);
	code_edit.gui_input.connect(gui_input.emit)
	code_edit.gui_input.connect(unset_meta)
	set_cursor_mode(mode_label.text)


func remove_code_edit():
	if not code_edit:
		return
	code_edit.caret_changed.disconnect(caret_moved_emit);
	code_edit.gui_input.disconnect(gui_input.emit)
	code_edit.gui_input.disconnect(unset_meta)
	set_cursor_mode('insert')
	mode_label.remove_form_parent();
	code_edit = null

func set_mode(mode:String):
	set_cursor_mode(mode);
	mode_label.set_mode(mode);
	pass
func set_caret_pos(pos: Vector2i):
	CodeEditInfo.set_caret_pos(code_edit,pos);
	
func get_caret_pos()->Vector2i:
	return CodeEditInfo.get_caret_pos(code_edit);


func caret_moved_emit():
	if code_edit.get_meta("moving_programmatically"):
		return
	caret_moved.emit(get_caret_pos());

func set_cursor_mode(mode: String):
	if mode == 'insert':
		code_edit.caret_type = CodeEdit.CARET_TYPE_LINE
		code_edit.caret_blink = true;
	else:
		code_edit.caret_type = CodeEdit.CARET_TYPE_BLOCK
		code_edit.caret_blink = false;
