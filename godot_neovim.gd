@tool
extends EditorPlugin
const MsgPack := 		preload("res://addons/godot-neovim/msgpack.gd")
const EventParser := 	preload("res://addons/godot-neovim/event_parser.gd")
const PLUGIN_NAME : String = "godot-neovim" 
var _nvim_connection := NvimConnection.new();
var _nvim_api_requester:=NvimApiRequester.constructor(_nvim_connection)
var _editor_callback_manager:= EditorCallbackManager.constructer(_nvim_api_requester);
var _nvim_subprocess := NvimSubprocess.new();
var mode_label:Label = Label.new();
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
class NvimConnection:
	enum MSG_PACK_RPC_TYPES {
		REQUEST = 0,
		RESPONSE = 1,
		NOTIFICATION = 2,
	}
	var _neovim_tcp_connection := StreamPeerTCP.new();
	var _msgid := 0 ;
	var _get_responses: bool = true;
	var _mode_label:Label
	func setup(mode_label: Label):
		_mode_label = mode_label
		_neovim_tcp_connection.connect_to_host("127.0.0.1", 6666);
		var status = StreamPeerTCP.Status.STATUS_CONNECTING;
		while status == StreamPeerTCP.Status.STATUS_CONNECTING:
			_neovim_tcp_connection.poll()
			status =  _neovim_tcp_connection.get_status();
		if status == StreamPeerTCP.Status.STATUS_ERROR:
			push_error("failed to connect to nvim")
	func send_request(method_name: String, params: Array):
		_neovim_tcp_connection.put_data(MsgPack.encode([
 			MSG_PACK_RPC_TYPES.REQUEST,
  			_msgid,               
  			method_name,      
  			params
		]).result);
		_msgid= (_msgid + 1)%128; # ill probably need a better way to handle this
	func _handle_redraw(commands: Array):
		for command in commands:
			var command_string: String = command[0];
			#print(command_string);
			if command_string == "mode_change":
				_mode_label.text = command[1][0];
				print(command);
		
	func _handle_responses(responses: Array):
		for response in responses:
			if (response[0] == NvimConnection.MSG_PACK_RPC_TYPES.NOTIFICATION and 
			 	response[1] == "redraw"): 
				#print(response);
				_handle_redraw(response[2])
	func process():
		if not _get_responses:
			return
		var res = _neovim_tcp_connection.get_data(_neovim_tcp_connection.get_available_bytes());
		var err = res[0]
		var data= res[1]
		if err == 0  and not data.is_empty():
			var decoded = MsgPack.decode_multiple(data);
			if decoded.error != OK:
				printerr("Error decoding: "+ decoded.error_string)
			
			_handle_responses(decoded.result)
			#print(data)
		elif err != 0:
			print("Connection error: " + error_string(err))
			_get_responses = false
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
class NvimApiRequester:
	var _connection :NvimConnection
	static func constructor(connection:NvimConnection)->NvimApiRequester:
		var ret = NvimApiRequester.new();
		ret._connection = connection;
		return ret
	func attach_ui( code_edit: CodeEdit):
		var code_dimensions:= code_edit.size
		if code_edit.minimap_draw:
			code_dimensions.x -= code_edit.minimap_width
		code_dimensions.x -= code_edit.get_total_gutter_width()
		var font :Font=code_edit.get_theme_font("font")
		var char_dimension: Vector2=font.get_char_size(32, code_edit.get_theme_font_size("font_size"))
		var terminal_dimensions := Vector2i( code_dimensions/char_dimension)
		# this is really inacurate please fix this 
		_connection.send_request("nvim_ui_attach", [terminal_dimensions.x, terminal_dimensions.y,{}])
	func go_insert_mode():
		_connection.send_request("nvim_input", ["i"])
	func sync_caret(code_edit:CodeEdit):
		var line := code_edit.get_caret_line() + 1 #might be specific to my config
		var col :=  code_edit.get_caret_column()
		_connection.send_request("nvim_win_set_cursor",[0,[line,col]])
	func process_text_edit_gui_input(event: InputEvent):
		if event is InputEventKey and event.is_pressed():
			var parsed = EventParser.parse(event)
			if parsed : 
				_connection.send_request("nvim_input", [ parsed])
	func change_file(script:Script):
		var file_path:String = ProjectSettings.globalize_path(script.resource_path)
		_connection.send_request("nvim_command", ['e! ' + file_path])
class EditorCallbackManager:
	var _nvim_api_requester: NvimApiRequester
	var _code_edit_properties:= CodeEditPropertiesMap.new();
	static func constructer(nvim_api_requester: NvimApiRequester)->EditorCallbackManager:
		var ret = EditorCallbackManager.new();
		ret._nvim_api_requester = nvim_api_requester;
		return ret;
	func setup_file_changed(script_editor: ScriptEditor):
		var code_edit:= script_editor.get_current_editor().get_base_editor() as CodeEdit
		script_editor.editor_script_changed.connect(func(script:Script):
			_nvim_api_requester.change_file(script);
			var _code_edit:= script_editor.get_current_editor().get_base_editor() as CodeEdit
			#_setup_caret_moved_callback(_code_edit)
			setup_gui_input(code_edit)
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

func _enter_tree() -> void:
	#_start_nvim()
	var script_editor := EditorInterface.get_script_editor();
	var code_edit:= script_editor.get_current_editor().get_base_editor() as CodeEdit
	_nvim_connection.setup(mode_label)
	_editor_callback_manager.setup_file_changed(script_editor);
	_nvim_api_requester.attach_ui(code_edit)
	_nvim_api_requester.go_insert_mode()
	_editor_callback_manager.setup_gui_input(code_edit)
	var status_bar: HBoxContainer= code_edit.get_parent().get_child(1)
	status_bar.add_child( mode_label)
	status_bar.move_child(mode_label, 2)

	#_setup_caret_moved_callback(code_edit) 
	# 
		

func _process(delta: float) -> void:
	_nvim_connection.process()
	


func _exit_tree() -> void:
	mode_label.queue_free();
	_nvim_connection.send_request("nvim_ui_detach",[]);
	_nvim_subprocess.kill();



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
