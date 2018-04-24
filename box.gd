extends ColorRect


func _gui_input(event):
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			# TODO Convert to canvas coordinates
			rect_position += event.relative

