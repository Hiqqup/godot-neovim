extends CodeEditHandler
const CodeEditHandler:= preload("res://addons/godot-neovim/code_edit_handler.gd")
const CodeEditHandlerStub:=preload("res://test/stubs/code_edit_handler_stub.gd")
const Plugin:=preload("res://addons/godot-neovim/plugin.gd")
func remove_code_edit():
	var _code_edit = code_edit;
	super.remove_code_edit();
	if _code_edit:
		_code_edit.free();
static func constructor(plugin: Plugin)->CodeEditHandlerStub:
	if plugin: plugin.code_edit_handler.mode_label.free();
	var new = CodeEditHandlerStub.new();
	new.CodeEditInfo = CodeEditInfoStub;
	new.mode_label.free()
	new.mode_label = ModeLabelStub.new();
	if plugin: plugin.editor_events.file_changed.connect(new.change_file)
	return new;
func cleanup():
	mode_label.remove_form_parent();
	mode_label.free();
func change_file(path:String):
	set_code_edit();
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file: %s" % path)
		return;
	code_edit.text = file.get_as_text();
	#print(code_edit.text);
class ModeLabelStub extends ModeLabel:
	var has_parent:= false;
	func add_to_status_bar(_code_edit: CodeEdit):
		has_parent = true;
	func remove_form_parent():
		has_parent = false
class CodeEditInfoStub extends CodeEditInfoDependencyInjection:
	static func get_current_code_edit()->CodeEdit:
		return CodeEdit.new();
