extends Node2D


var Box = load("res://box.tscn")


#func _ready():
#	connect("gui_input", self, "_gui_input")


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				var box = Box.instance()
				var pos = get_global_mouse_position()
				box.rect_position = pos - Vector2(32, 16)
				add_child(box)




