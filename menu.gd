extends Panel


signal mode_selected(mode)

const Editor = preload("editor.gd")

onready var _box_button = get_node("HBoxContainer/BoxButton")
onready var _line_button = get_node("HBoxContainer/LineButton")


func _ready():
	var group = ButtonGroup.new()
	_box_button.group = group
	_line_button.group = group
	
	_box_button.connect("pressed", self, "_on_box_mode_pressed")
	_line_button.connect("pressed", self, "_on_line_mode_pressed")
	

func _on_box_mode_pressed():
	emit_signal("mode_selected", Editor.MODE_BOX)


func _on_line_mode_pressed():
	emit_signal("mode_selected", Editor.MODE_LINE)


