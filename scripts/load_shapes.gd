extends Node

var saveload : Node

var info : Dictionary
var models : Dictionary
var thumbnails : Dictionary

var loaded : bool = false
signal done_loading
	
func _ready():
	get_saveload()
	load_models()
	load_info()
	emit_signal("done_loading")
	loaded = true
	
func get_saveload():
	if saveload == null: saveload = get_tree().root.get_node("world").get_node("saveload")
		
func load_models():
	models.clear()
	var files = saveload.parse_dir("res://assets/models/shapes", ".glb")
	for turr in files:
		models[turr] = load("res://assets/models/shapes/" + turr)
		
func load_thumbnails():
	thumbnails.clear()
	var files = saveload.parse_dir("res://assets/textures/thumbnails/enemies", ".png")
	for turr in files:
		print(turr)
		thumbnails[turr] = load("res://assets/textures/thumbnails/enemies/" + turr)

func load_info():
	info.clear()
	var files = saveload.parse_dir("res://assets/json", ".json")
	for f in files:
		if f != "enemies.json": continue
		var parsed = saveload.load_parse_json("res://assets/json/" + f)
		if parsed != null:
			for tin in parsed:
				info[tin.name] = tin
