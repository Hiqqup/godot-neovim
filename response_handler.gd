const EditorState:=preload("res://addons/godot-neovim/editor_state.gd")
class T:
	static func constructor()->T:
		var ret := T.new();
		return ret;
	func _handle_redraw(commands: Array):
		for command in commands:
			var command_string: String = command[0];
			#print(command_string);
			if command_string == "mode_change":
				EditorState.T.singleton.mode = command[1][0];
				EditorState.Util.set_cursor_mode();
			if command_string == "win_viewport":
				var params: Array = command[1];
				var line = params[4];
				var column = params[5]
				EditorState.T.singleton.current_code_edit.set_caret_line(line)
				EditorState.T.singleton.current_code_edit.set_caret_column(column)
				#print(command);
	func handle_responses(responses: Array):
		for response in responses:
			const RPC_NOTIFICATION:=2
			if (response[0] == RPC_NOTIFICATION and
				response[1] == "redraw"):
				#print(response);
				_handle_redraw(response[2])
