extends GutTest

const NvimEventParser:=preload("res://addons/godot-neovim/nvim_event_parser.gd")
var event_parser := NvimEventParser.new();


func test_mode_changed():
	var mode = "insert";
	watch_signals(event_parser);
	event_parser.parse([[1, 10, null, 1], [2, "redraw", [["mode_change", [mode, 2]], ["flush", []]]]]);
	assert_signal_emitted_with_parameters(event_parser, "mode_changed", [mode]);

func test_curser_moved():
	var pos:= Vector2i(0,15)
	watch_signals(event_parser);
	event_parser.parse([[1, 20, null, null], [2, "redraw", [["win_viewport", [2, { "type": 1, "data": [205, 3, 232] }, 0, 28, 15, 0, 38, 0]], ["flush", []]]]])
	assert_signal_emitted_with_parameters(event_parser, "cursor_moved", [pos]);

func test_new_buffer():
	watch_signals(event_parser)
	event_parser.parse([[2, "new_buffer", [3, "/home/ju/Documents/projects/gd/godot-neovim-tests/addons/godot-neovim/mode_label.gd"]]])
	assert_signal_emitted(event_parser, "new_buffer")
