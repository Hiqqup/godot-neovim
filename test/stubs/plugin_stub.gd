extends Plugin
const Plugin := preload("res://addons/godot-neovim/plugin.gd")
const CodeEditHandlerStub:= preload("res://test/stubs/code_edit_handler_stub.gd")
const NvimConnectionStub:= preload("res://test/stubs/nvim_connection_stub.gd")
const EditorSetupStub:=preload("res://test/stubs/editor_setup_stub.gd")
const NvimBufferManagerStub:= preload("res://test/stubs/nvim_buffer_manager_stub.gd")

func _notification(what: int) -> void:
	if what != NOTIFICATION_ENTER_TREE:
		return
	code_edit_handler = CodeEditHandlerStub.constructor(self);
	editor_setup = EditorSetupStub.new();
	nvim_connection = NvimConnectionStub.new();
	nvim_buffer_manager = NvimBufferManagerStub.new();
	super._enter_tree();
func _enter_tree():
	editor_events.file_changed.disconnect(code_edit_handler.set_code_edit)
func _exit_tree():
	code_edit_handler.cleanup();
