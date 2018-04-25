extends Control


onready var _menu = get_node("Menu")
onready var _editor = get_node("Canvas")


func _ready():
	_menu.connect("mode_selected", _editor, "set_mode")

