extends Node

var saveload : Node
var models : Dictionary

var loaded = false
signal done_loading
	
func get_saveload():
	if saveload == null: saveload = get_tree().root.get_node("world").get_node("saveload")
	
func _ready():
	get_saveload()
	load_models()
	emit_signal("done_loading")
	loaded = true
	
func load_models():
	models = {}
	var dir = Directory.new()
	dir.open("res://assets/models/shapes")
	dir.list_dir_begin(true)
	var shape = dir.get_next()
	while shape != "":
		if (shape.ends_with(".glb")):
			var model = load("res://assets/models/shapes/" + shape)
			var sname = shape.substr(0, shape.length()-4)
			models[sname] = model
		shape = dir.get_next()
