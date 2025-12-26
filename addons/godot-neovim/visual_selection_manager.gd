
var mode: String
var code_edit: CodeEdit
var selection_starting_point: Vector2i
var line_to_caret_id: Dictionary[int, int]
func set_mode(_mode: String):
	mode = _mode
	if mode.substr(0, 6) != "visual":
		code_edit.deselect();
		code_edit.caret_multiple =false;
		code_edit.caret_multiple = true;
func set_code_edit(_code_edit:CodeEdit):
	code_edit = _code_edit


func set_selection_starting_point(pos:Vector2i):
	selection_starting_point = pos
func cursor_moved(pos: Vector2i):
	var from:= selection_starting_point + Vector2i(0, -1)
	var to:= pos + Vector2i(0,0)
	if mode == "visual":
		code_edit.select(from.y, from.x, to.y,to.x)
	if mode == "visual_line":
		if from.y <= to.y: 
			to.x = code_edit.get_line(to.y).length();
			from.x = 0
		else:
			from.x = code_edit.get_line(from.y).length();
			to.x = 0
		code_edit.select(from.y, from.x, to.y, to.x);
	if mode == "visual_block":
		if from.y > to.y:
			var tmp:= from
			from = to
			to = tmp
		#print("form: " + str(from) + " to: " + str(to))
		var line_range = range(from.y, to.y + 1 )
		for y in line_range :
			if line_to_caret_id.has(y):
				code_edit.select(y, from.x, y, to.x, line_to_caret_id[y]);
				continue
			var caret_id = code_edit.add_caret(to.x, y);
			line_to_caret_id[y] = caret_id
			code_edit.select(y, from.x, y, to.x, caret_id);
		for i in line_to_caret_id.keys():
			if i not in line_range:
				var caret_id = line_to_caret_id[i]
				if caret_id != 0:
					code_edit.remove_caret(caret_id)
				line_to_caret_id.erase(i)
