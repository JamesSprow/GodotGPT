extends TextEdit

signal prompt_submitted

func _gui_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	event = event as InputEventKey
	if not event.pressed:
		return
	if event.keycode != KEY_ENTER:
		return
	if Input.is_key_pressed(KEY_SHIFT):
		# add newline to text because enter event doesn't propagate?
		# also need to handle moving the caret to the new line after we add it
		var caret_line: int = get_caret_line(0)
		var caret_col: int = get_caret_column(0)
		text += "\n"
		set_caret_line(caret_line + 1)
		set_caret_column(0)
		return
	
	# if we reach this point, enter was pressed while shift was not held down
	# therefore the user is trying to submit a prompt
	
	# set input as handled so it doesn't propagate
#	get_viewport().set_input_as_handled()
	accept_event()
	
	# emit prompt_submitted to notify root node to send a chat request
	prompt_submitted.emit()
	
