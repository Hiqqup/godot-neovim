extends GutTest
const VimModeState:= preload("res://addons/godot-neovim/vim_mode_state.gd")

var vim_mode_state := VimModeState.new();


func test_input_handeled():
	watch_signals(vim_mode_state)
	vim_mode_state.mode = "normal"
	vim_mode_state.check_input(InputEventKey.new())
	assert_signal_emitted(vim_mode_state, "input_handeled")

func test_input_not_handeled():
	watch_signals(vim_mode_state)
	vim_mode_state.mode = "insert"
	vim_mode_state.check_input(InputEventKey.new())
	assert_signal_not_emitted(vim_mode_state, "input_handeled")
