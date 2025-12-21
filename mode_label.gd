const EditorState := preload("res://addons/godot-neovim/editor_state.gd")
class T extends  Label:
	func set_mode(mode: String):
		text = mode
	func setup_status_bar(code_edit: CodeEdit):
		var status_bar: HBoxContainer= code_edit.get_parent().get_child(1)
		status_bar.add_child( self)
		status_bar.move_child(self, 2)
