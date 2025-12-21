const EditorState := preload("res://addons/godot-neovim/editor_state.gd")
const NvimApiRequester:= preload("res://addons/godot-neovim/nvim_api_requester.gd")
class T:
	var _nvim_api_requester: NvimApiRequester.T
	var _code_edit_properties:= CodeEditPropertiesMap.new();
	var _connections: Array[Connection];
	static func constructor(nvim_api_requester: NvimApiRequester.T)->T:
		var ret = T.new();
		ret._nvim_api_requester = nvim_api_requester;
		return ret;
	func clear_pointers_disconnect_connections()->void:
		for connection in _connections:
			connection.discon();
		_connections = []
		_nvim_api_requester = null
		_code_edit_properties = null
	func setup_file_changed(script_editor: ScriptEditor):
		var code_edit:= script_editor.get_current_editor().get_base_editor() as CodeEdit
		_connections.append(Connection.constructor(
			script_editor,
			script_editor.editor_script_changed,
			(func(script:Script):
			_nvim_api_requester.change_file(script);
			var _code_edit:= script_editor.get_current_editor().get_base_editor() as CodeEdit
			setup_caret_moved(_code_edit)
			setup_gui_input(code_edit)
			EditorState.T.singleton.current_code_edit = _code_edit;
			)
		))
	func setup_caret_moved(code_edit: CodeEdit):
		var props:=_code_edit_properties.get_properties(code_edit);
		if props.caret_moves:
			return
		props.caret_moves = true;
		_connections.append(Connection.constructor(
			code_edit,
			code_edit.caret_changed,
			(func(): _nvim_api_requester.sync_caret(code_edit))
		))
	func setup_gui_input(code_edit:CodeEdit):
		var props:=_code_edit_properties.get_properties(code_edit);
		if props.input_forwarded:
			return
		props.input_forwarded = true;
		code_edit.gui_input.connect(_nvim_api_requester.process_text_edit_gui_input)

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
class Connection:
	var object:Object
	var sig: Signal
	var callback: Callable
	static func constructor(_object:Object,_sig: Signal,_callback: Callable)->Connection:
		var ret = Connection.new();
		ret.sig=_sig
		ret.object=_object
		ret.callback=_callback
		ret.con();
		return ret
	func con():
		object.connect(sig.get_name(), callback);
	func discon():
		object.disconnect(sig.get_name(), callback)
	
