extends Node

var saveload : Node

var info : Dictionary
var models : Dictionary
var thumbs : Dictionary

var loaded : bool = false
signal done_loading

func _ready():
	get_saveload()
	load_models()
	load_info()
	emit_signal("done_loading")
	loaded = true

func get_saveload():
	if saveload == null: saveload = get_tree().root.get_child(0).get_node("saveload")
	
func get_base_turrets():
	var results = []
	for turr in info.values():
		var flag = true
		for oth in info.values():
			if oth.name == turr.name: continue
			if turr.name in oth.upgrades:
				flag = false
		if flag: results.append(turr)
	return results

func load_info():
	info.clear()
	var files = saveload.parse_dir("res://assets", ".json")
	for turr in files:
		var parsed = saveload.load_parse_json("res://assets/" + turr)
		if parsed != null:
			for tin in parsed:
				info[tin.name] = tin
	
func load_models():
	models.clear()
	var files = saveload.parse_dir("res://models/turrets", ".glb")
	for turr in files:
		models[turr] = load("res://models/turrets/" + turr)
	
func load_thumbs():
	thumbs.clear()
	var files = saveload.parse_dir("res://textures/thumbnails", ".png")
	for turr in files:
		thumbs[turr] = load("res://textures/thumbnails/" + turr)
