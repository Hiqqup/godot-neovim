@tool
extends EditorPlugin
const EventParser := 	preload("res://addons/godot-neovim/event_parser.gd")
const NvimConnection := preload("res://addons/godot-neovim/nvim_connection.gd")
const NvimApiRequester:=preload("res://addons/godot-neovim/nvim_api_requester.gd")
const EditorState:= 	preload("res://addons/godot-neovim/editor_state.gd")
class CodeEditProperties:
	var caret_moves :=false
	var input_forwarded :=false
class CodeEditPropertiesMap:
	var map: Dictionary[CodeEdit, CodeEditProperties]
	func get_properties(code_edit: CodeEdit) -> CodeEditProperties:
		if map.has(code_edit):
			return map[code_edit];
		map[code_edit] = CodeEditProperties.new();
		return map[code_edit];
class ResponseHandler:
	static func constructor()->ResponseHandler:
		var ret := ResponseHandler.new();
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
				print(command);
		
	func handle_responses(responses: Array):
		for response in responses:
			const RPC_NOTIFICATION:=2
			if (response[0] == RPC_NOTIFICATION and
				response[1] == "redraw"):
				#print(response);
				_handle_redraw(response[2])
class NvimSubprocess:
	var _neovim_pid: int = PID_UNASSIGNED;
	const PID_UNASSIGNED:int = 0;
	func start():
		# start with this command nvim --listen 127.0.0.1:6666 -u /home/ju/code/3d_squash_the_creeps_starter/addons/godot-neovim/init.lua
		var args: PackedStringArray = ["--listen", "127.0.0.1:6666"]#, "--embed", "--headless"]
		_neovim_pid = OS.create_process("nvim", args);
		print(_neovim_pid)
	func kill():
		if _neovim_pid != PID_UNASSIGNED:
			OS.kill(_neovim_pid)
class EditorCallbackManager:
	var _nvim_api_requester: NvimApiRequester.T
	var _code_edit_properties:= CodeEditPropertiesMap.new();
	static func constructor(nvim_api_requester: NvimApiRequester.T)->EditorCallbackManager:
		var ret = EditorCallbackManager.new();
		ret._nvim_api_requester = nvim_api_requester;
		return ret;
	func clear_pointers()->void:
		_nvim_api_requester = null
		_code_edit_properties = null
	func setup_file_changed(script_editor: ScriptEditor):
		var code_edit:= script_editor.get_current_editor().get_base_editor() as CodeEdit
		script_editor.editor_script_changed.connect(func(script:Script):
			_nvim_api_requester.change_file(script);
			var _code_edit:= script_editor.get_current_editor().get_base_editor() as CodeEdit
			#_setup_caret_moved_callback(_code_edit)
			setup_gui_input(code_edit)
			EditorState.T.singleton.current_code_edit = _code_edit;
			)
	func setup_caret_moved(code_edit: CodeEdit):
		var props:=_code_edit_properties.get_properties(code_edit);
		if props.caret_moves:
			return
		props.caret_moves = true;
		code_edit.caret_changed.connect(func(): _nvim_api_requester.sync_caret(code_edit))
	func setup_gui_input(code_edit:CodeEdit):
		var props:=_code_edit_properties.get_properties(code_edit);
		if props.input_forwarded:
			return
		props.input_forwarded = true;
		code_edit.gui_input.connect(_nvim_api_requester.process_text_edit_gui_input)

	

func _enable_plugin() -> void:
	pass

func _disable_plugin() -> void:
	pass


var _nvim_connection: NvimConnection.T;
var _nvim_api_requester:NvimApiRequester.T
var _editor_callback_manager: EditorCallbackManager
func _enter_tree() -> void:
	#_start_nvim() 
	
	EditorState.T.singleton = EditorState.T.new();
	var _response_handler = ResponseHandler.constructor();
	_nvim_connection = NvimConnection.T.constructor();
	_nvim_connection.recieved.connect(
		func(responses:Array):_response_handler.handle_responses(responses))
	
	_nvim_api_requester=NvimApiRequester.T.constructor(_nvim_connection, self)
	_editor_callback_manager= EditorCallbackManager.constructor(_nvim_api_requester);
	
	var script_editor := EditorInterface.get_script_editor();
	var code_edit:= script_editor.get_current_editor().get_base_editor() as CodeEdit
	EditorState.T.singleton.current_code_edit = code_edit;
	_editor_callback_manager.setup_file_changed(script_editor);
	_nvim_api_requester.attach_ui(code_edit)
	#_nvim_api_requester.go_insert_mode()
	_editor_callback_manager.setup_gui_input(code_edit)
	var status_bar: HBoxContainer= code_edit.get_parent().get_child(1)
	EditorState.T.singleton.add_label_to_status_bar(status_bar);

	#_setup_caret_moved_callback(code_edit) 
	# 
		

func _process(delta: float) -> void:
	_nvim_connection.process()
	


func _exit_tree() -> void:
	_nvim_connection.send_request("nvim_ui_detach",[]);
	EditorState.T.singleton.mode = "insert"
	EditorState.Util.set_cursor_mode();
	EditorState.T.singleton.free_label();
	EditorState.T.singleton = null
	_nvim_api_requester.clear_pointers();
	_nvim_api_requester = null
	_editor_callback_manager.clear_pointers()
	_editor_callback_manager = null
	#_nvim_subprocess.kill();



## logging

class FileDump:
	static func file_dump(node:Node):
		var file = FileAccess.open("res://dump.txt", FileAccess.WRITE)
		print_treee(file, node)
		
	static func print_treee(file:FileAccess , node: Node, indent: int = 0) -> void:
		var str = "";
		for i in range(indent):
			str+=" "
		str += str(node)
		if node is Label:
			str+=node.text
		str+= "\n"
		file.store_string(str);
		for child in node.get_children():
			print_treee(file, child, indent + 4)
