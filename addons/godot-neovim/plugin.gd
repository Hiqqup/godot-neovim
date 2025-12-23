extends Node
const NvimConnection := preload("res://addons/godot-neovim/nvim_connection.gd")
const NvimEventParser:= preload("res://addons/godot-neovim/nvim_event_parser.gd")
const NvimApiRequester:= preload("res://addons/godot-neovim/nvim_api_requester.gd")
const EditorEvents:= preload("res://addons/godot-neovim/editor_events.gd")
const EditorGuiInputParser:= preload("res://addons/godot-neovim/editor_gui_input_event_parser.gd")
const CodeEditHandler:= preload("res://addons/godot-neovim/code_edit_handler.gd")
const VimModeState:= preload("res://addons/godot-neovim/vim_mode_state.gd")
const EditorSetup:=preload("res://addons/godot-neovim/editor_setup.gd")
var nvim_connection:=NvimConnection.new();
var nvim_event_parser:=NvimEventParser.new();
var nvim_api_requester:=NvimApiRequester.new();
var editor_events:= EditorEvents.new();
var editor_gui_input_parser:= EditorGuiInputParser.new();
var code_edit_handler:=CodeEditHandler.new();
var vim_mode_state:=VimModeState.new();
var editor_setup:=EditorSetup.new();
func _enter_tree():
	editor_events.file_changed.connect(code_edit_handler.set_code_edit);
	editor_events.file_changed.connect(nvim_api_requester.change_file);
	code_edit_handler.caret_moved.connect(nvim_api_requester.move_caret);
	code_edit_handler.gui_input.connect(editor_gui_input_parser.parse);
	code_edit_handler.gui_input.connect(vim_mode_state.check_input);
	editor_gui_input_parser.parsed.connect(nvim_api_requester.send_input);
	editor_gui_input_parser.input_handeled.connect(get_viewport().set_input_as_handled)
	vim_mode_state.input_handeled.connect(get_viewport().set_input_as_handled);
	nvim_api_requester.request.connect(nvim_connection.send_request);
	nvim_connection.recieved.connect(nvim_event_parser.parse);
	nvim_event_parser.mode_changed.connect(vim_mode_state.set_mode);
	nvim_event_parser.cursor_moved.connect(code_edit_handler.set_caret_pos);
	nvim_event_parser.mode_changed.connect(code_edit_handler.set_mode);
	
	editor_setup.file_changed.connect(editor_events.file_changed.emit);
	editor_setup.set_code_edit_requested.connect(code_edit_handler.set_code_edit);
	editor_setup.connection_establish_requested.connect(nvim_connection.establish_connection);
	editor_setup.ui_attach_requested.connect(nvim_api_requester.attach_ui);
	editor_setup.open_current_file_requested.connect(nvim_api_requester.change_file);
	editor_setup.setup();

func _exit_tree():
	nvim_api_requester.detatch_ui()
	code_edit_handler.remove_code_edit();

func _process(_delta: float) -> void:
	nvim_connection.process();
