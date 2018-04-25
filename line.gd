extends Node2D

const Groups = preload("groups.gd")
const ControlPointScene = preload("control_point.tscn")

onready var _mid = get_node("Mid")
onready var _end = null

var _subdivided_mid = null
var _curve = null
var _control_points = []


func _ready():
	append_point(Vector2())
	append_point(Vector2())
	
	#_subdivided_mid = _mid.duplicate()


func destroy():
	for cp in _control_points:
		cp.destroy()
	queue_free()


func set_begin_pos(pos):
	set_point_pos(0, pos)


func set_end_pos(pos):
	set_point_pos(_mid.get_point_count() - 1, pos)


func set_point_pos(i, pos, notify_cp=true):
	_mid.set_point_position(i, pos)
	if notify_cp:
		_control_points[i].position = pos


func append_point(pos):
	_mid.add_point(pos)
	var cp = ControlPointScene.instance()
	cp.position = pos
	cp.set_line(self, _mid.get_point_count() - 1)
	get_parent().add_child(cp)
	_control_points.append(cp)


func remove_point(i):
	_mid.remove_point(i)
	var cp = _control_points[i]
	_control_points.remove(i)
	for j in range(i, len(_control_points)):
		_control_points[j].set_line(self, j)
	cp.destroy()


func get_control_point(i):
	return _control_points[i]


func get_point_count():
	return len(_control_points)


#func auto_attach_point(i):
#	var pos = _mid.get_point_position(i)
#	var box = get_box_at(pos)


#func get_box_at(pos):
#	var boxes = get_tree().get_nodes_in_group(Groups.BOXES)
#	for box in boxes:
#		if box.get_rect().has_point(pos):
#			return box
#	return null

