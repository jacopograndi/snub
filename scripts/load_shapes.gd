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
	calc_cost()
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


func calc_cost ():
	for i in info: info[i].cost = get_lives(i)

func get_lives (name):
	var i = info[name]
	var hp = i.lives
	for n in i.get("spawn_num", 0):
		hp += get_lives(i.spawn_on_death)
	return hp
	
func get_damage (hp, name):
	var i = info[name]
	var dam = hp * i.damage
	for n in i.get("spawn_num", 0):
		var spawn_info = info[i.spawn_on_death]
		dam += get_damage(spawn_info.lives, i.spawn_on_death)
	return dam
