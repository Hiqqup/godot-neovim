@tool
extends EditorPlugin
const EventParser := 			preload("res://addons/godot-neovim/event_parser.gd")
const NvimConnection := 		preload("res://addons/godot-neovim/nvim_connection.gd")
const NvimApiRequester:=		preload("res://addons/godot-neovim/nvim_api_requester.gd")
const EditorState:= 			preload("res://addons/godot-neovim/editor_state.gd")
const EditorCallbackManager:=	preload("res://addons/godot-neovim/editor_callback_manager.gd")
const ResponseHandler:=			preload("res://addons/godot-neovim/response_handler.gd")
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

func _enable_plugin() -> void:
	pass

func _disable_plugin() -> void:
	pass


var _nvim_connection: NvimConnection.T;
var _nvim_api_requester:NvimApiRequester.T
var _editor_callback_manager: EditorCallbackManager.T
func _enter_tree() -> void:
	EditorState.global= EditorState.CodeEditManager.new();
	#_start_nvim() 
	
	var _response_handler:= ResponseHandler.T.constructor();
	_nvim_connection = NvimConnection.T.constructor();
	_nvim_connection.recieved.connect(
		func(responses:Array):_response_handler.handle_responses(responses))
	
	_nvim_api_requester=NvimApiRequester.T.constructor(_nvim_connection, self)
	_editor_callback_manager= EditorCallbackManager.T.constructor(_nvim_api_requester);
	
	var script_editor := EditorInterface.get_script_editor();
	var code_edit:= script_editor.get_current_editor().get_base_editor() as CodeEdit
	EditorState.global.current = code_edit;
	_editor_callback_manager.setup_file_changed(script_editor);
	_nvim_api_requester.attach_ui(code_edit)
	#_nvim_api_requester.go_insert_mode()
	_editor_callback_manager.setup_gui_input(code_edit)
	_editor_callback_manager.setup_status(code_edit);

	_editor_callback_manager.setup_caret_moved(code_edit) 
	 
		

func _process(delta: float) -> void:
	_nvim_connection.process()
	


func _exit_tree() -> void:
	_nvim_connection.send_request("nvim_ui_detach",[]);
	EditorState.global.mode = "insert"
	EditorState.set_cursor_mode();
	EditorState.global.clear_pointers();
	EditorState.global = null
	_nvim_api_requester.clear_pointers();
	_nvim_api_requester = null
	_editor_callback_manager.clear_pointers_disconnect_connections()
	_editor_callback_manager = null
	EditorState.global = null
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
