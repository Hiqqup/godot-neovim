const NvimEventParser:=preload("res://addons/godot-neovim/nvim_event_parser.gd")
const BufferLineEventData = preload("res://addons/godot-neovim/buffer_line_event_data.gd")
signal mode_changed(mode:String)
signal cursor_moved(pos: Vector2i)
signal new_buffer(buffer_id:int, path:String)
signal lines_changed(buffer_id: int, lines_data:BufferLineEventData)
signal insert_enter
signal insert_leave
signal insert_leave_pre
signal visual_selection_started(pos: Vector2i)

const RPC_NOTIFICATION:=2
const RPC_RESPONSE:=1;
func parse(data: Array):
	for response in data:
		if (response[0] == RPC_NOTIFICATION):
			match response[1]:
				"new_buffer":
					new_buffer.emit(response[2][0], response[2][1]);
				"redraw":
					_handle_redraw(response[2])
				"nvim_buf_lines_event":
					var lines_data = BufferLineEventData.new(response[2])
					lines_changed.emit(lines_data.buffer_id, lines_data);
				"insert_enter":
					insert_enter.emit();
				"insert_leave":
					insert_leave.emit()
				"visual_enter":
					mode_changed.emit("visual" + response[2][0])
				"visual_selection_start":
					var pos: = Vector2i(response[2][0][1], response[2][0][0])
					visual_selection_started.emit(pos)
				_:
					print(response[1])
		
		if (response[0] == RPC_RESPONSE and response[2] !=null):
			push_error(response);

func _handle_redraw(commands: Array):
	for command in commands:
		var command_string: String = command[0];
		#print(command_string);
		if command_string == "mode_change":
			var mode =command[1][0];
			if mode != "visual":
				mode_changed.emit(mode)
		if command_string == "win_viewport":
			var params: Array = command[1];
			var line = params[4];
			var column = params[5]
			var pos :=Vector2i(column,line)
			#print(pos)
			cursor_moved.emit(pos)
