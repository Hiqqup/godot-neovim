const NvimEventParser:=preload("res://addons/godot-neovim/nvim_event_parser.gd")
const BufferLineEventData = preload("res://addons/godot-neovim/buffer_line_event_data.gd")
signal mode_changed(mode:String)
signal cursor_moved(pos: Vector2i)
signal new_buffer(buffer_id:int, path:String)
signal lines_changed(buffer_id: int, lines_data:BufferLineEventData)

const RPC_NOTIFICATION:=2
const RPC_RESPONSE:=1;
func parse(data: Array):
	for response in data:
		if (response[0] == RPC_NOTIFICATION):
			if (response[1] == "new_buffer"):
				new_buffer.emit(response[2][0], response[2][1]);
			elif (response[1] == "redraw"):
				_handle_redraw(response[2])
			elif (response[1] == "nvim_buf_lines_event"):
				print(response);
				var lines_data = BufferLineEventData.new(response[2])
				lines_changed.emit(lines_data.buffer_id, lines_data);
		if (response[0] == RPC_RESPONSE and response[2] !=null):
			print(response);

func _handle_redraw(commands: Array):
	for command in commands:
		var command_string: String = command[0];
		#print(command_string);
		if command_string == "mode_change":
			mode_changed.emit(command[1][0])
		if command_string == "win_viewport":
			var params: Array = command[1];
			var line = params[4];
			var column = params[5]
			var pos :=Vector2i(column,line)
			#print(pos)
			cursor_moved.emit(pos)
