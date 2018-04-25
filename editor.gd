extends Node2D

const Groups = preload("groups.gd")
const Box = preload("res://box.gd")
const Line = preload("res://line.gd")
const ControlPoint = preload("res://control_point.gd")
const Graph = preload("res://graph.gd")

var BoxScene = load("res://box.tscn")
var LineScene = load("res://line.tscn")

const MODE_BOX = 0
const MODE_LINE = 1

const ZOOM_FACTOR = 1.5

onready var _camera = get_node("Camera2D")

var _mode = MODE_BOX
var _current_line = null
var _hover_items = {}

var _graph = null


func _ready():
	_graph = Graph.new()


func add_item(item):
	_graph.add_item(item)


func remove_item(item):
	_graph.remove_item(item)


func set_mode(mode):
	if _mode == mode:
		return
	
	print("Set mode ", mode)
	_mode = mode
	
	if _mode != MODE_LINE:
		if _current_line != null:
			_current_line.destroy()
			_current_line = null
	
	var boxes = get_tree().get_nodes_in_group(Groups.BOXES)
	var filter = Control.MOUSE_FILTER_STOP if _mode == MODE_BOX else Control.MOUSE_FILTER_IGNORE
	for box in boxes:
		box.mouse_filter = filter


func _unhandled_input(event):
	
	if event is InputEventMouseButton:
		if event.pressed:
			
			match event.button_index:
				BUTTON_LEFT:
					
					match _mode:
						MODE_BOX:
							var box = BoxScene.instance()
							var pos = get_global_mouse_position()
							box.rect_position = pos - Vector2(32, 16)
							add_child(box)
						
						MODE_LINE:
							if _current_line == null:
								var line = LineScene.instance()
								var pos = get_global_mouse_position()
								add_child(line)
								line.set_begin_pos(pos)
								line.set_end_pos(pos)
								
								try_attach_control_point(line, 0)
								
								_current_line = line
								
							else:
								if event.control:
									var mpos = get_global_mouse_position()
									try_attach_control_point(_current_line, _current_line.get_point_count() - 1)
									_current_line.append_point(mpos)
								else:
									try_attach_control_point(_current_line, _current_line.get_point_count() - 1)
									_current_line = null
							
				BUTTON_RIGHT:
					match _mode:
						MODE_LINE:
							if _current_line != null:
								if _current_line.get_point_count() <= 2:
									_current_line.destroy()
									_current_line = null
								else:
									_current_line.remove_point(_current_line.get_point_count() - 1)
									_current_line = null
		
	elif event is InputEventMouseMotion:
		match _mode:
			MODE_LINE:
				if _current_line != null:
					var mpos = get_global_mouse_position()
					_current_line.set_end_pos(mpos)


func _input(event):
	if event is InputEventMouseButton:
		match event.button_index:
			
			BUTTON_WHEEL_UP:
				_zoom(1.0 / ZOOM_FACTOR, get_global_mouse_position())
			
			BUTTON_WHEEL_DOWN:
				_zoom(ZOOM_FACTOR, get_global_mouse_position())
	
	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(BUTTON_MIDDLE):
			var rel = event.relative
			var wrel = screen_to_world_vector(rel)
			_camera.set_target_pos(_camera.position - wrel)


func _zoom(factor, pivot):
	var dpos = (pivot - _camera.position) * (1.0 - factor)
	_camera.tween_to_zoom(_camera.position + dpos, _camera.zoom * factor)


func screen_to_world_position(pos):
	return get_canvas_transform().affine_inverse().xform(pos)


func screen_to_world_vector(v):
	return get_canvas_transform().affine_inverse().basis_xform(v)


#func get_view_rect():
#	var screen_rect = get_viewport_rect()
#	var min_pos = screen_to_world_position(screen_rect.position)
#	var max_pos = screen_to_world_position(screen_rect.end)
#	return Rect2(min_pos, max_pos - min_pos)


func try_attach_control_point(line, i):
	if not _hover_items.empty():
		for item in _hover_items:
			if item is Box:
				var cp = line.get_control_point(i)
				cp.attach_to_box(item)
				break


func _physics_process(delta):
	var mpos = get_global_mouse_position()
	var state = get_world_2d().direct_space_state
	var hits = state.intersect_point(mpos)
	
	var old_items = {}
	for item in _hover_items:
		old_items[item] = true
	
	for hit in hits:
		var col = hit.collider
		
		var item = get_item_from_collider(col)
		if item == null:
			print("Could not find item from collider")
			continue
		
		_hover_items[item] = true

		if old_items.has(item):
			old_items.erase(item)
		else:
			if item.has_method("set_hover"):
				item.set_hover(true)
			item.connect("tree_exited", self, "_hover_item_exited_tree", [item])
	
	for item in old_items:
		_hover_items.erase(item)
		if item.has_method("set_hover"):
			item.set_hover(false)
		item.disconnect("tree_exited", self, "_hover_item_exited_tree")


func _hover_item_exited_tree(item):
	_hover_items.erase(item)


func get_item_from_collider(col):
	while col != self:
		if col is ControlPoint or col is Box or col is Line:
			return col
		col = col.get_parent()
	return null

