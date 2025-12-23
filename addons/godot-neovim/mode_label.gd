extends Label
func set_mode(mode: String):
	text = mode
func add_to_status_bar(code_edit: CodeEdit):
	var status_bar: HBoxContainer= code_edit.get_parent().get_child(1)
	status_bar.add_child( self)
	status_bar.move_child(self, 2)
func remove_form_parent():
	var parent: Node = get_parent();
	if parent:
		parent.remove_child(self)
