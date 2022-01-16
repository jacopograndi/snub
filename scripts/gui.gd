extends Control

var player : Node
var control : Node

var bottom_bar : Control
var top_bar : Control

func _fetch ():
	var root = get_tree().root.get_node("world")
	player = root.get_node("player")
	control = player.get_node("control")
	
	if bottom_bar == null: bottom_bar = get_node("bottom_bar")
	if top_bar == null: top_bar = get_node("top_bar")

func _ready():
	_fetch()

func refresh (in_editor : bool):
	_fetch()
	bottom_bar.refresh(in_editor)
	top_bar.refresh(in_editor)
