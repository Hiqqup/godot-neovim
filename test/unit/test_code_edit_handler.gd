extends GutTest
const CodeEditHandlerStub := preload("res://test/stubs/code_edit_handler_stub.gd")
var code_edit_handler := CodeEditHandlerStub.constructor(null);
func before_all():
	pass
func after_all():
	code_edit_handler.cleanup()
func before_each():
	code_edit_handler.set_code_edit()
func after_each():
	code_edit_handler.remove_code_edit()

func test_set_code_edit():
	code_edit_handler.remove_code_edit()
	code_edit_handler.set_code_edit()
	assert_ne(code_edit_handler.code_edit, null)
	assert_true(code_edit_handler.mode_label.has_parent);
	assert_true(code_edit_handler.code_edit.gui_input.has_connections())
	assert_true(code_edit_handler.code_edit.caret_changed.has_connections())

func test_set_mode():
	var mode = "insert"
	code_edit_handler.set_mode(mode);
	assert_eq(code_edit_handler.mode_label.text, mode);

func test_set_cursor_mode():
	code_edit_handler.set_mode("insert");
	assert_eq(  code_edit_handler.code_edit.caret_type, CodeEdit.CARET_TYPE_LINE)
	assert_true(code_edit_handler.code_edit.caret_blink)
	code_edit_handler.set_mode("normal")
	assert_eq(  code_edit_handler.code_edit.caret_type, CodeEdit.CARET_TYPE_BLOCK)
	assert_false(code_edit_handler.code_edit.caret_blink)


func test_remove_code_edit():
	code_edit_handler.remove_code_edit();
	assert_eq(code_edit_handler.code_edit, null)
	assert_false(code_edit_handler.mode_label.has_parent);
