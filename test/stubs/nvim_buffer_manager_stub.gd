extends NvimBufferManager
const NvimBufferManager:= preload("res://addons/godot-neovim/nvim_buffer_manager.gd")
const CodeEditInfoStub:= preload("res://test/stubs/code_edit_info_stub.gd")
func _init()->void:
	CodeEditInfo = CodeEditInfoStub;
func detach_buffers():
	super.detach_buffers()
	for id in buffer_id_to_mapping.keys():
		buffer_id_to_mapping[id].code_edit.free();
		buffer_id_to_mapping.erase(id)
