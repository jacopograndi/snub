extends Control

var player : Node
var control : Node
var wave : Node

var bottom_bar : Control
var top_bar : Control
var _wave_ongoing : Panel

func _fetch ():
	var root = get_tree().root.get_node("world")
	player = root.get_node("player")
	control = player.get_node("control")
	wave = root.get_node("wave")
	
	if bottom_bar == null: bottom_bar = get_node("bottom_bar")
	if top_bar == null: top_bar = get_node("top_bar")
	if _wave_ongoing == null: _wave_ongoing = $wave_ongoing_indicator

func _ready():
	_fetch()

func refresh ():
	_fetch()
	
	bottom_bar.refresh(control.ineditor)
	top_bar.refresh(control.ineditor)
	
	if wave.ongoing: _wave_ongoing.visible = true
	else: _wave_ongoing.visible = false
