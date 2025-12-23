@tool
extends EditorPlugin
const NvimConnection := preload("res://addons/godot-neovim/nvim_connection.gd")
const NvimEventParser:= preload("res://addons/godot-neovim/nvim_event_parser.gd")
const NvimApiRequester:= preload("res://addons/godot-neovim/nvim_api_requester.gd")
const EditorEvents:= preload("res://addons/godot-neovim/editor_events.gd")
const EditorGuiInputParser:= preload("res://addons/godot-neovim/editor_gui_input_event_parser.gd")
const CodeEditHandler:= preload("res://addons/godot-neovim/code_edit_handler.gd")
const VimModeState:= preload("res://addons/godot-neovim/vim_mode_state.gd")
const EditorSetup:=preload("res://addons/godot-neovim/editor_setup.gd")
var _nvim_connection:=NvimConnection.new();
var _nvim_event_parser:=NvimEventParser.new();
var _nvim_api_requester:=NvimApiRequester.new();
var _editor_events:= EditorEvents.new();
var _editor_gui_input_parser:= EditorGuiInputParser.new();
var _code_edit_handler:=CodeEditHandler.new();
var _vim_mode_state:=VimModeState.new();
var _editor_setup:=EditorSetup.new();
func _enable_plugin() -> void:
	pass
func _enter_tree() -> void:

	_editor_events.file_changed.connect(func(_script):_code_edit_handler.set_code_edit());
	_editor_events.file_changed.connect(_nvim_api_requester.change_file);
	_code_edit_handler.caret_moved.connect(_nvim_api_requester.move_caret);
	_code_edit_handler.gui_input.connect(_editor_gui_input_parser.parse);
	_code_edit_handler.gui_input.connect(_vim_mode_state.check_input);
	_editor_gui_input_parser.parsed.connect(_nvim_api_requester.send_input);
	_vim_mode_state.input_handeled.connect(func(): get_viewport().set_input_as_handled());
	_nvim_api_requester.request.connect(_nvim_connection.send_request);
	_nvim_connection.recieved.connect(_nvim_event_parser.parse);
	_nvim_event_parser.mode_changed.connect(_vim_mode_state.set_mode);
	_nvim_event_parser.cursor_moved.connect(_code_edit_handler.set_caret_pos);
	_nvim_event_parser.mode_changed.connect(_code_edit_handler.set_mode);
	
	_editor_setup.file_changed.connect(_editor_events.file_changed.emit);
	_editor_setup.set_code_edit_requested.connect(_code_edit_handler.set_code_edit);
	_editor_setup.connection_establish_requested.connect(_nvim_connection.establish_connection);
	_editor_setup.ui_attach_requested.connect(_nvim_api_requester.attach_ui);
	_editor_setup.open_current_file_requested.connect(_nvim_api_requester.change_file);
	_editor_setup.setup();


func _process(delta: float) -> void:
	_nvim_connection.process()
func _exit_tree() -> void:
	_nvim_api_requester.detatch_ui()
	_code_edit_handler.remove_code_edit();
func _disable_plugin() -> void:
	pass
