extends Node

var _path
var _enemy_blue
var _dissolve_mat

var _fx_holder
var _fx_enemy_damage

var _shapes = {}

var serial_enemy = 0
var enemies = {}


func _ready():
	_fx_holder = get_tree().root.get_child(0).find_node("fx")
	_path = get_tree().root.get_child(0).find_node("path")
	_dissolve_mat = load("res://shaders/dissolve_mat.tres")
	_enemy_blue = load("res://scenes/enemy.tscn")
	_fx_enemy_damage = load("res://scenes/fx/enemy_damage.tscn")
	
	load_shapes()
	
func load_shapes():
	_shapes = {}
	var dir = Directory.new()
	dir.open("res://models/shapes")
	dir.list_dir_begin(true)
	var shape = dir.get_next()
	while shape != "":
		if (shape.ends_with(".glb")):
			var model = load("res://models/shapes/" + shape)
			var sname = shape.substr(0, shape.length()-4)
			_shapes[sname] = model
		shape = dir.get_next()

func spawn():
	var instance = _enemy_blue.instance()
	add_child(instance)
	instance.transform.origin = _path.nodes[0].transform.origin;
	instance.name = str(serial_enemy)
	var instance_model = _shapes[_shapes.keys()[randi() % _shapes.size()]].instance()
	instance.add_child(instance_model)
	var axis : Vector3 = Quat(Vector3(0, randf()*TAU, 0)) * Vector3.RIGHT 
	enemies[serial_enemy] = { 
		"cur": 0, "hp": 10, "rel": 0, "ops": instance_model.name,
		"axis": [axis.x, axis.y, axis.z] }
	serial_enemy += 1
	
func node_from_id (id):
	return get_node(str(id))

func _physics_process(delta):
	var delist = []
	for child in get_children():
		var id = str(child.name).to_int()
		var enemy = enemies[id]
		
		if enemy.hp <= 0:
			if enemy.ops == "T":
				delist.append(id)
				enemy.rel = 0
				continue
			else:
				child.get_node(enemy.ops).queue_free()
				enemy.ops = enemy.ops.substr(1, enemy.ops.length()-1)
				enemy.hp = 10
				var instance_model = _shapes[enemy.ops].instance()
				child.add_child(instance_model)
			
		var speed = 1
		enemy.rel += speed * delta
		while enemy.rel > 1: 
			enemy.rel -= 1
			enemy.cur += 1
		
		var destination = enemy.cur+1
		if destination >= _path.nodes.size():
			delist.append(id)
			enemy.rel = 0
			continue
			
		var from = _path.nodes[enemy.cur].transform.origin
		var to = _path.nodes[destination].transform.origin
		child.transform.origin = lerp(from, to, enemy.rel)
		
		var axis = Vector3(enemy.axis[0], enemy.axis[1], enemy.axis[2])
		child.transform.basis = child.transform.basis.rotated(axis, delta)
	
	for id in delist:
		get_node(str(id)).queue_free()
		enemies.erase(id)


func damage(name):
	var id = int(name)
	var enemy = enemies[id]
	enemies[id].hp -= 1
	
	fx_damage(name)
	
func fx_damage(name):
	var id = int(name)
	var enemy = enemies[id]
	
	var instance = _fx_enemy_damage.instance()
	_fx_holder.add_child(instance)
	
	var node = node_from_id(id)
	instance.transform = node.transform;
	instance.refresh_basis()
	
	var instance_model = _shapes[enemy["ops"]].instance()
	instance.add_child(instance_model)
	
	instance.refresh_shader(_dissolve_mat)
