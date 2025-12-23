extends GutTest
const ModeLabel:= preload("res://addons/godot-neovim/mode_label.gd")
var code_edit_stub: CodeEdit;
var parent_node : Node;
var status_bar: HBoxContainer;
func before_all():
	parent_node= Node.new();
	code_edit_stub = CodeEdit.new();
	status_bar = HBoxContainer.new();
	parent_node.add_child(code_edit_stub)
	parent_node.add_child(status_bar)
	for i in range(5): # dummy elements
		status_bar.add_child(Node.new());

func after_all():
	parent_node.free();

func test_add_to_status_bar():
	var mode_label: ModeLabel;
	mode_label = ModeLabel.new();
	mode_label.add_to_status_bar(code_edit_stub);
	assert_eq(mode_label.get_parent(), status_bar)
	mode_label.remove_form_parent();
	assert_ne(mode_label.get_parent(), status_bar)
	mode_label.free()
