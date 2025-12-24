const CodeEditBufferMapping:= preload("res://addons/godot-neovim/code_edit_buffer_mapping.gd")
const CodeEditInfoDependencyInjection:= preload("res://addons/godot-neovim/code_edit_info.gd")
var CodeEditInfo:= CodeEditInfoDependencyInjection;
signal buffer_detatched(buffer_id:int)
var mappings:Dictionary[int, CodeEditBufferMapping];
func setup_mapping(buffer_id:int, path:String):
	var mapping := CodeEditBufferMapping.new();
	var code_edit:= CodeEditInfo.get_current_code_edit();
	var path_from_editor :=CodeEditInfo.get_file_path(CodeEditInfo.get_current_script())
	if (path_from_editor != path ):
		push_error("Script path from neovim and from editor dont match:"
			+path +"!="+ path_from_editor)
	mapping.code_edit = code_edit;
	mapping.buffer_id = buffer_id
	mappings[buffer_id] = (mapping)
	#print("attached");
func forward_lines_data(buffer_id:int, lines_data):
	mappings[buffer_id].handle_lines_data(lines_data);

func detach_buffers():
	for id in mappings.keys():
		buffer_detatched.emit(mappings[id].buffer_id)
	
