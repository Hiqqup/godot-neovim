@tool
extends EditorPlugin
const NvimConnection := preload("res://addons/godot-neovim/nvim_connection.gd")
const NvimEventParser:= preload("res://addons/godot-neovim/nvim_event_parser.gd")
const NvimApiRequester:= preload("res://addons/godot-neovim/nvim_api_requester.gd")
const EditorEvents:= preload("res://addons/godot-neovim/editor_events.gd")
const EditorGuiInputParser:= preload("res://addons/godot-neovim/editor_gui_input_event_parser.gd")
const CodeEditHandler:= preload("res://addons/godot-neovim/code_edit_handler.gd")
const CodeEditInfo:=preload("res://addons/godot-neovim/code_edit_info.gd")
const VimModeState:= preload("res://addons/godot-neovim/vim_mode_state.gd")
var _nvim_connection:=NvimConnection.new();
var _nvim_event_parser:=NvimEventParser.new();
var _nvim_api_requester:=NvimApiRequester.new();
var _editor_events:= EditorEvents.new();
var _editor_gui_input_parser:= EditorGuiInputParser.new();
var _code_edit_handler:CodeEditHandler;
var _vim_mode_state:=VimModeState.new();
var _replace_code_edit_handler:=(func(_path:=""): _code_edit_handler = CodeEditHandler.replace(_code_edit_handler,_editor_events))
func _enable_plugin() -> void:
	pass
func _enter_tree() -> void:

	_editor_events.file_changed.connect(_replace_code_edit_handler);
	_editor_events.file_changed.connect(_nvim_api_requester.change_file)
	_editor_events.caret_moved.connect(_nvim_api_requester.move_caret)
	_editor_events.gui_input.connect(_editor_gui_input_parser.parse);
	_editor_events.gui_input.connect(_vim_mode_state.check_input);
	_editor_gui_input_parser.parsed.connect(_nvim_api_requester.send_input);
	_vim_mode_state.input_handeled.connect(func(): get_viewport().set_input_as_handled());
	_nvim_api_requester.request.connect(_nvim_connection.send_request);
	_nvim_connection.recieved.connect(_nvim_event_parser.parse);
	_nvim_event_parser.mode_changed.connect(_vim_mode_state.set_mode)
	_nvim_event_parser.cursor_moved.connect(func(pos): _code_edit_handler.set_caret(pos));
	_nvim_event_parser.mode_changed.connect(func(mode): _code_edit_handler.set_mode(mode))
	
	_editor_events.setup();
	_replace_code_edit_handler.call();
	_nvim_connection.establish_connection();
	_setup_ui_attach();
	_open_current_file();


func _process(delta: float) -> void:
	_nvim_connection.process()
func _exit_tree() -> void:
	_nvim_api_requester.detatch_ui()
	_code_edit_handler.delete();
func _disable_plugin() -> void:
	pass




func _setup_ui_attach():
	var script_editor := EditorInterface.get_script_editor();
	var code_edit:= script_editor.get_current_editor().get_base_editor() as CodeEdit
	var dimensions:= CodeEditInfo.get_dimensions(code_edit)
	_nvim_api_requester.attach_ui(dimensions)

func _open_current_file():
	var script_editor := EditorInterface.get_script_editor();
	var script:= script_editor.get_current_script();
	var script_path := CodeEditInfo.get_file_path(script)
	_nvim_api_requester.change_file(script_path)
