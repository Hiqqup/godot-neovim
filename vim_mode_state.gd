signal input_handeled

var mode: String = "";

func set_mode(_mode:String):
	mode = _mode;
func check_input(any_event: InputEvent):
	var event:= any_event as InputEventKey
	if not event:
		return
	if mode != "insert":
		input_handeled.emit();
