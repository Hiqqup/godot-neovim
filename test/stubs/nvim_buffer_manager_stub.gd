extends NvimBufferManager
const NvimBufferManager:= preload("res://addons/godot-neovim/nvim_buffer_manager.gd")
const CodeEditInfoStub:= preload("res://test/stubs/code_edit_info_stub.gd")
func _init()->void:
	CodeEditInfo = CodeEditInfoStub;
func detach_buffers():
	super.detach_buffers()
	for id in mappings.keys():
		mappings[id].code_edit.free();
		mappings.erase(id)
