const NvimConnection := preload("res://addons/godot-neovim/nvim_connection.gd")
const EventParser := 	preload("res://addons/godot-neovim/event_parser.gd")
const EditorState := preload("res://addons/godot-neovim/editor_state.gd")
class T:
	
	var _connection :NvimConnection.T
	var _editor_plugin: EditorPlugin;
	static func constructor(connection:NvimConnection.T, editor_plugin: EditorPlugin)->T:
		var ret = T.new();
		ret._connection = connection;
		ret._editor_plugin = editor_plugin;
		return ret
	func clear_pointers()->void:
		_connection = null
		_editor_plugin = null
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
	func sync_caret(code_edit:CodeEdit):
		var line := code_edit.get_caret_line() + 1 #might be specific to my config
		var col :=  code_edit.get_caret_column()
		_connection.send_request("nvim_win_set_cursor",[0,[line,col]])
	func process_text_edit_gui_input(event: InputEvent):
		if event is InputEventKey and event.is_pressed():
			var parsed = EventParser.parse(event)
			if parsed :
				_connection.send_request("nvim_input", [ parsed])
			if EditorState.global.mode != "insert":
				_editor_plugin.get_viewport().set_input_as_handled()
	func change_file(script:Script):
		var file_path:String = ProjectSettings.globalize_path(script.resource_path)
		_connection.send_request("nvim_command", ['e! ' + file_path])
