extends Plugin
const Plugin := preload("res://addons/godot-neovim/plugin.gd")
const CodeEditHandlerStub:= preload("res://test/stubs/code_edit_handler_stub.gd")
const NvimConnectionStub:= preload("res://test/stubs/nvim_connection_stub.gd")
const EditorSetupStub:=preload("res://test/stubs/editor_setup_stub.gd")
const NvimBufferManagerStub:= preload("res://test/stubs/nvim_buffer_manager_stub.gd")
var real_connection_flag:= false

func _init(real_connection:= false):
	real_connection_flag = real_connection
func _enter_tree():
	code_edit_handler = CodeEditHandlerStub.constructor(self);
	editor_setup = EditorSetupStub.new();
	if not real_connection_flag: 
		nvim_connection = NvimConnectionStub.new();
	nvim_buffer_manager = NvimBufferManagerStub.new();
	super._enter_tree();
	editor_events.file_changed.disconnect(code_edit_handler.set_code_edit)
func _exit_tree():
	super._exit_tree()
	code_edit_handler.cleanup();
