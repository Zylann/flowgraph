extends Node2D

const Groups = preload("groups.gd")
const ControlPointScene = preload("control_point.tscn")

onready var _mid = get_node("Mid")
onready var _end = null

var _points = []
var _control_points = []
var _pending_update = false


func _ready():
	append_point(Vector2())
	append_point(Vector2())


func destroy():
	for cp in _control_points:
		cp.destroy()
	queue_free()


func set_begin_pos(pos):
	set_point_pos(0, pos)


func set_end_pos(pos):
	set_point_pos(len(_points) - 1, pos)


func make_dirty():
	if not _pending_update:
		_pending_update = true
		call_deferred("_update_curved_line")


func set_point_pos(i, pos, notify_cp=true):
	_points[i] = pos
	if notify_cp:
		_control_points[i].position = pos
	make_dirty()


func append_point(pos):
	_points.append(pos)
	var cp = ControlPointScene.instance()
	cp.position = pos
	cp.set_line(self, len(_points) - 1)
	get_parent().add_child(cp)
	_control_points.append(cp)
	make_dirty()


func remove_point(i):
	_points.remove(i)
	var cp = _control_points[i]
	_control_points.remove(i)
	for j in range(i, len(_control_points)):
		_control_points[j].set_line(self, j)
	cp.destroy()
	make_dirty()


func get_control_point(i):
	return _control_points[i]


func get_point_count():
	return len(_points)


func _update_curved_line():
	var curve_points = _bezier_tessellate(_points, 100.0, 8)
	_mid.points = PoolVector2Array(curve_points)
	_pending_update = false


# Applies a form of curving that doesn't overrun segment turns
static func _bezier_tessellate(p_points, p_radius, p_steps=4):
	if len(p_points) == 0:
		return []
	elif len(p_points) == 1:
		return [p_points[0]]
	
	var out_points = [p_points[0]]
	
	for i in range(1, len(p_points) - 1):
		var p0 = p_points[i - 1]
		var p1 = p_points[i]
		var p2 = p_points[i + 1]
		
		# Divide by two to make sure we don't overlap with the next round corner
		var u0 = (p0 - p1) / 2.0
		var u2 = (p2 - p1) / 2.0
		p0 = p1 + u0
		p2 = p1 + u2
		
		var len0 = min(u0.length(), p_radius)
		var len2 = min(u2.length(), p_radius)
		
		var ip0 = p1 + u0.normalized() * len0
		var ip2 = p1 + u2.normalized() * len2
		
		if p0.distance_squared_to(out_points[-1]) > 0.1:
			out_points.append(p0)
		
		for j in range(1, p_steps):
			var t = float(j) / float(p_steps)
			var p = ip0.linear_interpolate(p1, t).linear_interpolate(p1.linear_interpolate(ip2, t), t)
			out_points.append(p)
		
		out_points.append(p2)
	
	if p_points[-1].distance_squared_to(out_points[-1]) < 0.1:
		out_points[-1] = p_points[-1]
	else:
		out_points.append(p_points[-1])
	
	return out_points


#func auto_attach_point(i):
#	var pos = _mid.get_point_position(i)
#	var box = get_box_at(pos)


#func get_box_at(pos):
#	var boxes = get_tree().get_nodes_in_group(Groups.BOXES)
#	for box in boxes:
#		if box.get_rect().has_point(pos):
#			return box
#	return null

