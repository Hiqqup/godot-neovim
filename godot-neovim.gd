@tool
extends EditorPlugin
const PID_UNASSIGNED:int = 0;
var PLUGIN_NAME : String = "godot-neovim"
var _neovim_pid: int = PID_UNASSIGNED;
var _neovim_tcp_connection := StreamPeerTCP.new();
var _msgid := 0 ;
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
var _code_edit_properties:= CodeEditPropertiesMap.new();
var _get_responses: bool = true;
enum MSG_PACK_RPC_TYPES {
	REQUEST = 0,
	RESPONSE = 1,
	NOTIFICATION = 2,
}

const MISC_KEYS:= {
		KEY_BACKSPACE: "BS",
		KEY_ESCAPE: "Esc",
		KEY_ENTER: "CR",
		KEY_TAB: "Tab",
		KEY_DELETE: "Del",
		KEY_UP: "Up",
		KEY_DOWN: "Down",
		KEY_LEFT: "Left",
		KEY_RIGHT: "Right",
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
	_msgid= (_msgid + 1)%128; # ill probably need a better way to handle this

func _setup_caret_moved_callback(code_edit: CodeEdit):
	var props:=_code_edit_properties.get_properties(code_edit);
	if props.caret_moves: 
		return
	props.caret_moves = true;
	code_edit.caret_changed.connect(func():
		var line := code_edit.get_caret_line() + 1 #might be specific to my config
		var col :=  code_edit.get_caret_column()
		_send_request("nvim_win_set_cursor",[0,[line,col]] )
		)


func _attach_nvim_ui(code_edit: CodeEdit):
	var code_dimensions:= code_edit.size
	if code_edit.minimap_draw:
		code_dimensions.x -= code_edit.minimap_width
	code_dimensions.x -= code_edit.get_total_gutter_width()
	var font :Font=code_edit.get_theme_font("font")
	var char_dimension: Vector2=font.get_char_size(32, code_edit.get_theme_font_size("font_size"))
	var terminal_dimensions := Vector2i( code_dimensions/char_dimension)
	# this is really inacurate please fix this 
	_send_request("nvim_ui_attach", [terminal_dimensions.x, terminal_dimensions.y,{}])
	
func _nvim_go_to_insert_mode():
	_send_request("nvim_input", ["i"])




func _parse_event_text(event: InputEventKey):
	
	var unicode :=event.unicode;
	if (unicode != 0&&
		!event.alt_pressed&&
		!event.ctrl_pressed&&
		!event.meta_pressed
		):
		return String.chr(unicode);
	var mask = "<"
	var keycode :Key = event.keycode;
	
	if (event.alt_pressed):
		mask+="A-"
	if(event.ctrl_pressed):
		mask+="C-"
	if(event.meta_pressed):
		mask+="M-"
	if(event.shift_pressed):
		mask+="S-"  

	
	if unicode != 0:
		mask+= String.chr(unicode);
	elif MISC_KEYS.has(keycode):
		mask+=MISC_KEYS[keycode];
	mask+=">"
	return mask
	
	

func _process_text_edit_gui_input(event: InputEvent):
	if event is InputEventKey and event.is_pressed():

		var parsed = _parse_event_text(event)
		if parsed : 
			_send_request("nvim_input", [ parsed])
			#_send_request("nvim_input", [event.as_text().to_lower()])
	pass

func _setup_gui_input_callback(code_edit: CodeEdit):
	var props:=_code_edit_properties.get_properties(code_edit);
	if props.input_forwarded: 
		return
	props.input_forwarded = true;
	code_edit.gui_input.connect(_process_text_edit_gui_input)

func _enter_tree() -> void:
	#_start_nvim()
	_connect_to_nvim()
	
	var script_editor := EditorInterface.get_script_editor();
	
	var code_edit:= script_editor.get_current_editor().get_base_editor() as CodeEdit
	_attach_nvim_ui(code_edit)
	_nvim_go_to_insert_mode()
	_setup_gui_input_callback(code_edit)
	script_editor.editor_script_changed.connect(func(script:Script):
		var file_path:String = ProjectSettings.globalize_path(script.resource_path)
		_send_request("nvim_command", ['e! ' + file_path])
		var _code_edit:= script_editor.get_current_editor().get_base_editor() as CodeEdit
		#_setup_caret_moved_callback(_code_edit)
		_setup_gui_input_callback(code_edit)
		)
		
	#_setup_caret_moved_callback(code_edit)
		

		
	#_send_request("nvim_command", ['echo "'+str(i)+' bar"'])
func _process(delta: float) -> void:
	if not _get_responses:
		return
	var res = _neovim_tcp_connection.get_data(_neovim_tcp_connection.get_available_bytes());
	var err = res[0]
	var data= res[1]
	if err == 0  and not data.is_empty():
		
		print("message: " + str(MsgPack.decode(data).result));
	elif err != 0:
		print("Connection error: " + error_string(err))
		_get_responses = false


func _exit_tree() -> void:
	_send_request("nvim_ui_detach",[]);
	if _neovim_pid != PID_UNASSIGNED:
		OS.kill(_neovim_pid)
