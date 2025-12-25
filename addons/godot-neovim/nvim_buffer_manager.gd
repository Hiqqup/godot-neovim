const CodeEditBufferMapping:= preload("res://addons/godot-neovim/code_edit_buffer_mapping.gd")
const CodeEditInfoDependencyInjection:= preload("res://addons/godot-neovim/code_edit_info.gd")
var CodeEditInfo:= CodeEditInfoDependencyInjection;
signal buffer_detatched(buffer_id:int)
signal update_lines(buffer_id:int, start:int, end:int, replacements: Array)
var buffer_id_to_mapping:Dictionary[int, CodeEditBufferMapping];
var code_edit_to_mapping:Dictionary[CodeEdit,CodeEditBufferMapping]
func setup_mapping(buffer_id:int, path:String):
	var code_edit:= CodeEditInfo.get_current_code_edit();
	verify_path(path)
	var mapping := CodeEditBufferMapping.new(code_edit, buffer_id);
	mapping.update_lines.connect(update_lines.emit);
	buffer_id_to_mapping[buffer_id] = mapping
	code_edit_to_mapping[code_edit] = mapping

func track_lines(pos):
	var code_edit:= CodeEditInfo.get_current_code_edit();
	code_edit_to_mapping[code_edit].track_lines(pos);
func track_current_line():
	var code_edit:= CodeEditInfo.get_current_code_edit();
	track_lines(CodeEditInfo.get_caret_pos(code_edit))

func forward_lines_data(buffer_id:int, lines_data):
	buffer_id_to_mapping[buffer_id].handle_lines_data(lines_data);

func detach_buffers():
	for id in buffer_id_to_mapping.keys():
		buffer_detatched.emit(buffer_id_to_mapping[id].buffer_id)
func get_lines_to_update():
	for id in buffer_id_to_mapping.keys():
		buffer_id_to_mapping[id].get_lines_to_update();

func verify_path(path:String):
	var path_from_editor := CodeEditInfo.get_file_path(CodeEditInfo.get_current_script())
	if (path_from_editor != path ):
		push_error("Script path from neovim and from editor dont match:"
			+path +"!="+ path_from_editor)
	return path_from_editor;
