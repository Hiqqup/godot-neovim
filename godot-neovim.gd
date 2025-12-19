@tool
extends EditorPlugin
const PID_UNASSIGNED:int = 0;
var _neovim_pid: int = PID_UNASSIGNED;
var _neovim_tcp_connection := StreamPeerTCP.new();
var _msgid := 0 ;
enum MSG_PACK_RPC_TYPES {
	REQUEST = 0,
	RESPONSE = 1,
	NOTIFICATION = 2,
}

func _enable_plugin() -> void:
	add_autoload_singleton("mgspack", "res://addons/godot-neovim/mgspack.gd")


func _disable_plugin() -> void:
	remove_autoload_singleton("mgspack")

func _start_nvim()->void:
	var args: PackedStringArray = ["--listen", "127.0.0.1:6666"]#, "--embed", "--headless"]
	_neovim_pid = OS.create_process("nvim", args);
	print(_neovim_pid)

func _connect_to_nvim():
	_neovim_tcp_connection.connect_to_host("127.0.0.1", 6666);
	var status = StreamPeerTCP.Status.STATUS_CONNECTING;
	while status == StreamPeerTCP.Status.STATUS_CONNECTING:
		_neovim_tcp_connection.poll()
		status =  _neovim_tcp_connection.get_status();
	if status == StreamPeerTCP.Status.STATUS_ERROR:
		push_error("failed to connect to nvim")

func _send_request(method_name: String, params: Array):
	_neovim_tcp_connection.put_data(MsgPack.encode([
 		MSG_PACK_RPC_TYPES.REQUEST,
  		_msgid,               
  		method_name,      
  		params
	]).result);
	_msgid+=1; # ill probably need a better way to handle this

func _enter_tree() -> void:
	#_start_nvim()
	_connect_to_nvim()	
	var script_editor := EditorInterface.get_script_editor();
	script_editor.editor_script_changed.connect(func(script:Script):
		var file_path:String = ProjectSettings.globalize_path(script.resource_path)
		_send_request("nvim_command", ['e ' + file_path])
		)
		
	var code_edit:= script_editor.get_current_editor().get_base_editor() as CodeEdit
	code_edit.caret_changed.connect(func():
		var line := code_edit.get_caret_line() + 1 #might be specific to my config
		var col :=  code_edit.get_caret_column()
		_send_request("nvim_win_set_cursor",[0,[line,col]] )
		)
		

		
	#_send_request("nvim_command", ['echo "'+str(i)+' bar"'])
func _process(delta: float) -> void:
	var res = _neovim_tcp_connection.get_data(_neovim_tcp_connection.get_available_bytes());
	var err = res[0]
	var data= res[1]
	if err == 0  and not data.is_empty():
		print(data);
	#else:
	#	push_error(err);
	#
func _exit_tree() -> void:
	if _neovim_pid != PID_UNASSIGNED:
		OS.kill(_neovim_pid)
