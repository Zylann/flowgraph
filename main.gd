extends Node


onready var _menu = get_node("CanvasLayer/Menu")
onready var _editor = get_node("Canvas")


func _ready():
	_menu.connect("mode_selected", _editor, "set_mode")

