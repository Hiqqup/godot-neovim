var buffer_id:int
var first_line:int;
var last_line:int
var line_data:Array

func _init(event : Array):
	buffer_id= event[0]["buffer"]["data"][0]
	first_line= event[2] ;
	last_line= event[3];
	line_data = event[4]

func print_data():
	print({
	buffer_id =buffer_id,
	first_line = first_line,
	last_line = last_line,
	line_data = line_data,
	})
func get_lines_with_index()->Dictionary[int, String]:
	var ret:={}

	return ret;
