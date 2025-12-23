extends GutTest
const NvimApiRequester:= preload("res://addons/godot-neovim/nvim_api_requester.gd")
var nvim_api_requester:=NvimApiRequester.new();
func test_change_file():
	send_request(func():nvim_api_requester.change_file(""), "nvim_command");

func test_send_input():
	send_request(func():nvim_api_requester.send_input(""),"nvim_input");

func test_attach_ui():
	send_request(func():nvim_api_requester.attach_ui(Vector2i.ZERO),"nvim_ui_attach")

func test_detach_ui():
	send_request(func():nvim_api_requester.detatch_ui(), "nvim_ui_detach")


func send_request(callable:Callable, response_command:String):
	watch_signals(nvim_api_requester)
	callable.call();
	assert_signal_emitted(nvim_api_requester , "request")
	assert_eq(response_command, get_signal_parameters(nvim_api_requester,"request")[0])
