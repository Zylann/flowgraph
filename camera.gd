extends Camera2D


var _target_pos = Vector2()
var _target_zoom = Vector2()
var _tween_begin_pos = Vector2()
var _tween_begin_zoom = Vector2()
var _tween_time = 0.0
var _tween_duration = 0.1


func _ready():
	set_process(false)


func tween_to_zoom(p_pos, p_zoom):
	_tween_begin_pos = position
	_tween_begin_zoom = zoom
	_target_pos = p_pos
	_target_zoom = p_zoom
	_tween_time = 0.0
	set_process(true)


func set_target_pos(pos):
	_target_pos = pos
	if not is_processing():
		position = pos


func _process(delta):
	_tween_time += delta
	if _tween_time > _tween_duration:
		_tween_time = _tween_duration
		set_process(false)
	
	var t = _tween_curve(_tween_time / _tween_duration)
	
	position = _tween_begin_pos.linear_interpolate(_target_pos, t)
	zoom = _tween_begin_zoom.linear_interpolate(_target_zoom, t)
	

func _tween_curve(x):
	x -= 1.0
	return 1.0 - x * x

