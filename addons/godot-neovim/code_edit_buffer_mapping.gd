
const BufferLineEventData:=preload("res://addons/godot-neovim/buffer_line_event_data.gd");
var code_edit:CodeEdit
var buffer_id :int;
var tracked_lines: Dictionary[int, bool]
signal update_lines(buffer_id:int, start:int, end:int, replacements: Array)

func _init(_code_edit:CodeEdit, _buffer_id: int) -> void:
	code_edit = _code_edit
	buffer_id = _buffer_id;

func handle_lines_data(d:BufferLineEventData):
	code_edit.set_meta("moving_programmatically", true)
	#d.print_data();
	if d.first_line != d.last_line:
		code_edit.select(d.first_line, 0, d.last_line ,0)
		code_edit.delete_lines()
	for i in range(d.line_data.size()):
		code_edit.insert_line_at(d.first_line+i , d.line_data[i]);

func track_lines(pos:Vector2i):
	tracked_lines[pos.y - 1] = true;
	#print(tracked_lines)

func get_lines_to_update():
	for line in tracked_lines.keys():
		var text := code_edit.get_line(line);
		#print({id=buffer_id,st=line,end= line+1,con= [text]})
		update_lines.emit(buffer_id, line, line+1, [text]);
	
	tracked_lines.clear()
