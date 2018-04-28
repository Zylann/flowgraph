extends Node2D

var _line = null
var _line_index = 0
var _box = null

#var _normalized_attachment_pos = Vector2()


func _ready():
	var canvas = get_parent()
	canvas.add_item(self)


func set_line(line, index):
	_line = line
	_line_index = index


func destroy():
	var canvas = get_parent()
	canvas.remove_item(self)
	if _box != null:
		_box.remove_attached_control_point(self)
	queue_free()


func attach_to_box(box):
	_box = box
	_box.add_attached_control_point(self)
	update_attached_pos()


func detach_from_box():
	_box.remove_attached_control_point(self)
	_box = null


func update_attached_pos():
	var rs = _box.rect_size
	position = _box.rect_position + 0.5 * rs
	_update_line()


func _update_line():
	_line.set_point_pos(_line_index, position, false)	
	# Don't use NOTIFICATION_TRANSFORM_CHANGED for that purpose. Makes things hard to control.
