signal input_handeled

var mode: String = "";
signal input_forwarded(input: InputEventKey)
signal caret_should_move(pos)
signal track_lines(pos)
signal exited_insert_mode();
signal entered_insert_mode();
func set_mode(_mode:String):
	var old_mode = mode;
	mode = _mode;
	if old_mode == "insert" and _mode !="insert":
		exited_insert_mode.emit();
	if old_mode != "insert" and _mode =="insert":
		entered_insert_mode.emit();
func check_should_move_caret(pos):
	if mode == "insert":
		track_lines.emit(pos);
	else:
		caret_should_move.emit(pos)
func check_input(any_event: InputEvent):
	var event:= any_event as InputEventKey
	if not event:
		return
	if mode != "insert":
		input_handeled.emit();
		input_forwarded.emit(event)
	if mode == "insert" and is_escape_seqence(event):
		input_forwarded.emit(event);

func is_escape_seqence(event:InputEventKey):
	return (
		event.keycode == KEY_ESCAPE or 
		event.unicode == ord("c") and event.ctrl_pressed or
		event.keycode == ord("[") and event.ctrl_pressed
		)
