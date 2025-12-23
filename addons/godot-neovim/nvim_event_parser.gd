const NvimEventParser:=preload("res://addons/godot-neovim/nvim_event_parser.gd")


signal mode_changed(mode:String)
signal cursor_moved(pos: Vector2i)

func parse(data: Array):
	#print(data);
	for response in data:
		const RPC_NOTIFICATION:=2
		if (response[0] == RPC_NOTIFICATION and
			response[1] == "redraw"):
			#print(response);
			_handle_redraw(response[2])


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
