extends Node

var _resources : Node

var _path
var _enemy_blue
var _dissolve_mat : ShaderMaterial
var _enemy_mat : Material

var _fx_holder
var _fx_enemy_damage

var serial_enemy = 0
var enemies = {}

var load_shapes : Node

var colors = [
	Color.red,
	Color.purple,
	Color.blue,
	Color.mediumseagreen,
	Color.green,
	Color.greenyellow,
	Color.yellow,
	Color.orange,
	Color.violet,
	Color.indigo,
]


func _ready():
	var root = get_tree().root.get_node("world")
	_fx_holder = root.get_node("fx")
	_path = root.get_node("path")
	_resources = root.get_node("player").get_node("resources")
	_dissolve_mat = load("res://shaders/dissolve_mat.tres")
	_enemy_mat = load("res://assets/models/shapes/Enemy.material")
	_enemy_blue = load("res://scenes/enemy.tscn")
	_fx_enemy_damage = load("res://scenes/fx/enemy_damage.tscn")
	
	var saveload = root.get_node("saveload")
	load_shapes = saveload.get_node("load_shapes")
	if !load_shapes.loaded: yield(load_shapes, "done_loading")

func spawn():
	var instance = _enemy_blue.instance()
	add_child(instance)
	instance.transform.origin = _path.nodes[0].transform.origin;
	instance.name = str(serial_enemy)
	var instance_model = load_shapes.models[load_shapes.models.keys()[randi() % load_shapes.models.size()]].instance()
	instance.add_child(instance_model)
	instance_model.get_child(0).set_surface_material(0, _enemy_mat.duplicate())
	
	var axis : Vector3 = Quat(Vector3(0, randf()*TAU, 0)) * Vector3.RIGHT 
	enemies[serial_enemy] = { 
		"cur": 0, "hp": 10, "rel": 0, "ops": instance_model.name,
		"axis": [axis.x, axis.y, axis.z] 
	}
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
				var instance_model = load_shapes.models[enemy.ops].instance()
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
		
		var mesh : MeshInstance = child.get_node(enemy.ops).get_child(0)
		mesh.get_active_material(0).albedo_color = colors[enemy.hp-1]
	
	for id in delist:
		get_node(str(id)).queue_free()
		enemies.erase(id)


func damage(name, amt):
	var id = int(name)
	var enemy = enemies[id]
	
	if enemy.hp > 0:
		enemy.hp -= amt
		_resources.add({ enemy.ops[0]: amt })
		fx_damage(name)
	
func fx_damage(name):
	var id = int(name)
	var enemy = enemies[id]
	
	var instance = _fx_enemy_damage.instance()
	_fx_holder.add_child(instance)
	
	var node = node_from_id(id)
	instance.transform = node.transform;
	instance.refresh_basis()
	
	var instance_model = load_shapes.models[enemy["ops"]].instance()
	instance.add_child(instance_model)
	
	instance.refresh_shader(_dissolve_mat.duplicate(), colors[enemy.hp-1])
