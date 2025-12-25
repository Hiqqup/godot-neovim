extends  GutTest
const PluginStub := preload("res://test/stubs/plugin_stub.gd")
const DontChangeThisScript:= preload("res://test/stubs/dont_change_this_script.gd")
var plugin := PluginStub.new();

func before_all():
	add_child(plugin);
func after_all():
	remove_child(plugin);
	plugin.free();

func after_each():
	plugin.code_edit_handler.remove_code_edit();
	plugin.nvim_buffer_manager.detach_buffers();

static func get_some_script_path()->String:
	return ProjectSettings.globalize_path((DontChangeThisScript as Script).resource_path);
func evaluate_api(apply_changes:Callable,command_string:String ):
	watch_signals(plugin.nvim_api_requester)
	apply_changes.call();
	assert_signal_emitted(plugin.nvim_api_requester , "request")
	assert_eq(command_string,get_signal_parameters(plugin.nvim_api_requester,"request")[0])

func test_response_mode_changed():
	plugin.nvim_connection.recieved.emit([[1, 10, null, 1], [2, "redraw", [["mode_change", ["normal", 2]], ["flush", []]]]]);
	assert_eq(  plugin.code_edit_handler.code_edit.caret_type, CodeEdit.CARET_TYPE_BLOCK)
	assert_eq( plugin.vim_mode_state.mode, "normal");
func test_response_cursor_moved():
	plugin.editor_events.file_changed.emit(get_some_script_path());
	var pos:= Vector2i(5,10);
	plugin.nvim_connection.recieved.emit([[1, 20, null, null], [2, "redraw", [["win_viewport", [2, { "type": 1, "data": [205, 3, 232] }, 10, 10, pos.y-1, pos.x, 10, 10, 10]], ["flush", []]]]])
	assert_eq(  plugin.code_edit_handler.get_caret_pos(), pos)
	
	
func test_file_change():
	evaluate_api(func():
		plugin.editor_events.file_changed.emit(get_some_script_path());
	,"nvim_command")
#func test_caret_moved():
#	var pos :=Vector2i(5,10);
#	evaluate_api(func():
#		plugin.editor_events.file_changed.emit(get_some_script_path());
#		plugin.code_edit_handler.set_caret_pos(pos);
#		plugin.code_edit_handler.code_edit.caret_changed.emit();
#	,"nvim_win_set_cursor")
#	var request_params: Array= get_signal_parameters(plugin.nvim_api_requester, "request")[1][1]
#	assert_eq(pos , Vector2i(request_params[1], request_params[0]-1))

func test_gui_input():
	plugin.vim_mode_state.mode = "normal"
	evaluate_api(func():
		var key_event = InputEventKey.new();
		key_event.pressed = true;
		key_event.unicode = ord("j")
		plugin.code_edit_handler.gui_input.emit(key_event);
	,"nvim_input")
	assert_true(get_viewport().is_input_handled());

func test_new_buffer():
	evaluate_api(func():
		plugin.nvim_connection.recieved.emit([[2, "new_buffer", [3, get_some_script_path()]]]);
	,"nvim_buf_attach")

func test_buf_lines_event():
	plugin.nvim_connection.recieved.emit([[2, "new_buffer", [3, get_some_script_path()]]]);
	plugin.nvim_connection.recieved.emit([[2, "nvim_buf_lines_event", [{ "buffer": { "type": "Buffer", "data": [3] }, "type": 0 }, 3, 9, 20, [], false]]])
	assert_true(true)

#func test_vim_state_exit_insert_mode():
#	var vms = plugin.vim_mode_state;
#	watch_signals(vms);
#	vms.set_mode("insert");
#	vms.set_mode("normal")
#	assert_signal_emitted(vms, "exited_insert_mode")
