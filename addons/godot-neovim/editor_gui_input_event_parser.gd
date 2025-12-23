
signal parsed(input_string:String)
signal event_handeled()

const MISC_KEYS:= {
	KEY_BACKSPACE: "BS",
	KEY_ESCAPE: "Esc",
	KEY_ENTER: "CR",
	KEY_TAB: "Tab",
	KEY_DELETE: "Del",
	KEY_UP: "Up",
	KEY_DOWN: "Down",
	KEY_LEFT: "Left",
	KEY_RIGHT: "Right",
}
const WIERD_UNICODES := {
	60: "<lt>"
}
func parse(any_event: InputEvent):
	var event:= any_event as InputEventKey
	if not event:
		return
	
	var unicode :=event.unicode;
	if WIERD_UNICODES.has(unicode):
		parsed.emit( WIERD_UNICODES[unicode]);
		return
	if (unicode != 0&&
		!event.alt_pressed&&
		!event.ctrl_pressed&&
		!event.meta_pressed
		):
		parsed.emit( String.chr(unicode));
		return
	var mask = "<"
	var keycode :Key = event.keycode;
	
	if (event.alt_pressed):
		mask+="A-"
	if(event.ctrl_pressed):
		mask+="C-"
	if(event.meta_pressed):
		mask+="M-"
	if(event.shift_pressed):
		mask+="S-" 

	if unicode != 0:
		mask+= String.chr(unicode);
	elif MISC_KEYS.has(keycode):
		mask+=MISC_KEYS[keycode];
	mask+=">"
	parsed.emit(mask)
