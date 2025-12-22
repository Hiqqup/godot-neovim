const CodeEditHandler:= preload("res://addons/godot-neovim/code_edit_handler.gd")
const EditorEvents:= preload("res://addons/godot-neovim/editor_events.gd")
const CodeEditInfo:= preload("res://addons/godot-neovim/code_edit_info.gd")
const ModeLabel:= preload("res://addons/godot-neovim/mode_label.gd")
var code_edit: CodeEdit # this shall be the only refence to it
var editor_events :EditorEvents
var mode_label:= ModeLabel.new();
static func replace(old: CodeEditHandler, editor_events: EditorEvents)->CodeEditHandler: # this will be used to replace the one reference
	if old:
		old.delete();
	var new := CodeEditHandler.new();
	var script_editor := EditorInterface.get_script_editor();
	var _code_edit:= script_editor.get_current_editor().get_base_editor() as CodeEdit
	new.setup(_code_edit, editor_events);
	return new;

func setup(_code_edit: CodeEdit, _editor_events: EditorEvents):
	code_edit = _code_edit
	editor_events = _editor_events;
	mode_label.add_to_status_bar(_code_edit);

	code_edit.caret_changed.connect(emit_caret_moved);
	code_edit.gui_input.connect(emit_gui_input)
	

func delete():
	code_edit.caret_changed.disconnect(emit_caret_moved);
	code_edit.gui_input.disconnect(emit_gui_input)
	set_cursor_mode('insert')
	mode_label.queue_free();

func set_mode(mode:String):
	set_cursor_mode(mode);
	mode_label.set_mode(mode);
	pass

func set_caret_pos(pos: Vector2i):
	code_edit.set_caret_line(pos.y)
	code_edit.set_caret_column(pos.x)

func get_caret_pos()->Vector2i:
	return CodeEditInfo.get_caret_pos(code_edit);

func set_cursor_mode(mode: String):
	if mode == 'insert':
		code_edit.caret_type = CodeEdit.CARET_TYPE_LINE
		code_edit.caret_blink = true;
	else:
		code_edit.caret_type = CodeEdit.CARET_TYPE_BLOCK
		code_edit.caret_blink = false;

func emit_caret_moved():
	editor_events.caret_moved.emit(CodeEditInfo.get_caret_pos(code_edit));
func emit_gui_input(event: InputEvent):
	editor_events.gui_input.emit(event);
