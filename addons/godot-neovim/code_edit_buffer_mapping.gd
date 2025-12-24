
const BufferLineEventData:=preload("res://addons/godot-neovim/buffer_line_event_data.gd");
var code_edit:CodeEdit
var buffer_id :int;
func handle_lines_data(d:BufferLineEventData):
	if d.first_line != d.last_line:
		code_edit.select(d.first_line, 0, d.last_line ,0)
		code_edit.delete_lines()
	for i in range(d.line_data.size()):
		code_edit.insert_line_at(d.first_line+i , d.line_data[i]);
