extends GutTest

const EditorGuiInputParser:= preload("res://addons/godot-neovim/editor_gui_input_event_parser.gd")
var editor_gui_input_parser:= EditorGuiInputParser.new();

func test_ignore_mouse_events():
	watch_signals(editor_gui_input_parser);
	var mouse_event:= InputEventMouseButton.new();
	editor_gui_input_parser.parse(mouse_event);
	assert_signal_not_emitted(editor_gui_input_parser, "parsed")

func test_input_letter():
	watch_signals(editor_gui_input_parser);
	var key_event = InputEventKey.new();
	key_event.unicode = ord("!")
	editor_gui_input_parser.parse(key_event);
	assert_signal_emitted_with_parameters(editor_gui_input_parser, "parsed", ["!"])
func test_input_control():
	watch_signals(editor_gui_input_parser);
	var key_event = InputEventKey.new();
	key_event.unicode = ord("a")
	key_event.ctrl_pressed = true;
	editor_gui_input_parser.parse(key_event);
	assert_signal_emitted_with_parameters(editor_gui_input_parser, "parsed", ["<C-a>"])
