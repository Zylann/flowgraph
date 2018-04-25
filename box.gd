extends ColorRect


var _attached_control_points = []


func _ready():
	var canvas = get_parent()
	canvas.add_item(self)
	
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(rect_size / 2)
	
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = shape
	
	var body = StaticBody2D.new()
	body.position = rect_size / 2
	body.add_child(collision_shape)
	add_child(body)


func destroy():
	var canvas = get_parent()
	canvas.remove_item(self)
	queue_free()
	
	for cp in _attached_control_points:
		cp.detach_from_box()
	_attached_control_points.clear()


func set_hover(v):
	#print("set_hover ", v)
	if v:
		self_modulate = Color(0,1,0,1)
	else:
		self_modulate = Color(1,1,1,1)


func add_attached_control_point(cp):
	_attached_control_points.append(cp)


func remove_attached_control_point(cp):
	_attached_control_points.erase(cp)


func _gui_input(event):
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			# TODO Convert to canvas coordinates
			rect_position += event.relative
			for cp in _attached_control_points:
				cp.update_attached_pos()

