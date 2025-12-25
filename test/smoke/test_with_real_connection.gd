extends GutTest
const PluginStub := preload("res://test/stubs/plugin_stub.gd")
const DontChangeThisScript:= preload("res://test/stubs/dont_change_this_script.gd")
var plugin := PluginStub.new(true);
func before_all():
	add_child(plugin);
func after_all():
	remove_child(plugin)
	plugin.free();
func after_each():
	plugin.code_edit_handler.remove_code_edit();
	plugin.nvim_buffer_manager.detach_buffers();
static func get_some_script_path()->String:
	return ProjectSettings.globalize_path((DontChangeThisScript as Script).resource_path);

func test_shift_j():
	plugin.code_edit_handler.caret_moved.connect(func():assert_true(false));
	plugin.editor_events.file_changed.emit(get_some_script_path())
	plugin.code_edit_handler.code_edit.text = (DontChangeThisScript as Script).source_code
	for i in range(20):
		plugin.nvim_api_requester.send_input("<S-j>")
		plugin.nvim_api_requester.send_input("u")
	assert_true(true);
