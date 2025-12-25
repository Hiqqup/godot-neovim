signal request(commands:String, params:Array)
func change_file(path: String):
	request.emit("nvim_command", ['e ' + path])
func move_caret(pos: Vector2i):
	request.emit("nvim_win_set_cursor",[0,[pos.y,pos.x]])
func send_input(input:String):
	request.emit("nvim_input", [ input])
func attach_ui(terminal_dimensions: Vector2i, options = {}):
	request.emit("nvim_ui_attach", [terminal_dimensions.x, terminal_dimensions.y,options])
func detatch_ui(): 
	request.emit("nvim_ui_detach",[]);
func attach_buffer(buffer_id: int, _p:=""):
	request.emit("nvim_buf_attach",[0, false,{}]);
func delete_buffer(buffer_id:int):
	request.emit("nvim_buf_delete", [buffer_id, {force = true}])
func buffer_set_lines(buffer_id:int, start:int, end:int, replacements: Array):
	request.emit("nvim_buf_set_lines",[buffer_id,start,end,false,replacements]);
