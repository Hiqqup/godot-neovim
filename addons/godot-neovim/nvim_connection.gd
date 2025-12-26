const MsgPack := preload("res://addons/godot-neovim/msgpack.gd")
enum MSG_PACK_RPC_TYPES {
	REQUEST = 0,
	RESPONSE = 1,
	NOTIFICATION = 2,
}
var _neovim_tcp_connection := StreamPeerTCP.new();
var _msgid := 0 ;
var _get_responses: bool = true;
signal recieved(responses: Array)
func establish_connection():
	_neovim_tcp_connection.connect_to_host("127.0.0.1", 6666);
	var status = StreamPeerTCP.Status.STATUS_CONNECTING;
	while status == StreamPeerTCP.Status.STATUS_CONNECTING:
		_neovim_tcp_connection.poll()
		status =  _neovim_tcp_connection.get_status();
	if status == StreamPeerTCP.Status.STATUS_ERROR:
		push_error("failed to connect to nvim")

func send_request(method_name: String, params: Array):
	var encoded=MsgPack.encode([
 		MSG_PACK_RPC_TYPES.REQUEST,
  		_msgid,               
  		method_name,      
  		params
	]);
	if encoded.error != Error.OK:
		push_error(encoded.error_string);
	_neovim_tcp_connection.put_data(encoded.result);
	_msgid= (_msgid + 1)%128; # ill probably need a better way to handle this
func process():
	if not _get_responses:
		return
	var res = _neovim_tcp_connection.get_data(_neovim_tcp_connection.get_available_bytes());
	var err = res[0]
	var data= res[1]
	if err == 0  and not data.is_empty():
		var decoded = MsgPack.decode_multiple(data);
		if decoded.error != OK:
			printerr("Error decoding: "+ decoded.error_string)			
			print(data);
		recieved.emit(decoded.result);
	elif err != 0:
		print("Connection error: " + error_string(err))
		_get_responses = false
