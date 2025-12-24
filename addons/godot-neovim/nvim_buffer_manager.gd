const CodeEditBufferMapping:= preload("res://addons/godot-neovim/code_edit_buffer_mapping.gd")
const CodeEditInfoDependencyInjection:= preload("res://addons/godot-neovim/code_edit_info.gd")
var CodeEditInfo:= CodeEditInfoDependencyInjection;
signal buffer_detatched(buffer_id:int)
var mappings:Array[CodeEditBufferMapping];
func setup_mapping(buffer_id:int, path:String):
	var mapping := CodeEditBufferMapping.new();
	var code_edit:= CodeEditInfo.get_current_code_edit();
	var path_from_editor :=CodeEditInfo.get_file_path(CodeEditInfo.get_current_script())
	if (path_from_editor != path ):
		push_error("Script path from neovim and from editor dont match:"
			+path +"!="+ path_from_editor)
	mapping.code_edit = code_edit;
	mapping.buffer_id = buffer_id
	mappings.append(mapping)
	print("attached");

func detach_buffers():
	for buffer in mappings:
		buffer_detatched.emit(buffer.buffer_id)
	
