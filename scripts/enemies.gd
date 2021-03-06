extends Node

var _resources : Node

var _path
var _enemy_blue
var _dissolve_mat : ShaderMaterial
var _enemy_mat : Material

var control
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
	control = root.get_node("player").get_node("control")
	_path = root.get_node("path")
	_resources = root.get_node("player").get_node("resources")
	_dissolve_mat = load("res://shaders/dissolve_mat.tres")
	_enemy_mat = load("res://assets/models/shapes/Enemy.material")
	_enemy_blue = load("res://scenes/enemy.tscn")
	_fx_enemy_damage = load("res://scenes/fx/enemy_damage.tscn")
	
	var saveload = root.get_node("saveload")
	load_shapes = saveload.get_node("load_shapes")
	if !load_shapes.loaded: yield(load_shapes, "done_loading")

func spawn(name, node_cur=0, rel_pos=0, hp=0):
	print("spawned " + name)
	var instance = _enemy_blue.instance()
	add_child(instance)
	instance.transform.origin = _path.nodes[0].transform.origin;
	instance.name = str(serial_enemy)
	var info = load_shapes.info[name]
	if hp == 0: hp = info.lives
	
	var instance_model = load_shapes.models[info.model_name].instance()
	instance.add_child(instance_model)
	instance_model.get_child(0).set_surface_material(0, _enemy_mat.duplicate())
	
	var axis : Vector3 = Quat(Vector3(0, randf()*TAU, 0)) * Vector3.RIGHT 
	enemies[serial_enemy] = { 
		"name": name, 
		"hp": hp, 
		"slow_effect": 0, 
		"slow_time": 0, 
		"cur": node_cur, 
		"rel": rel_pos, 
		"axis": [axis.x, axis.y, axis.z],
		"basecolor": Color(info.color[0], info.color[1], info.color[2], info.color[3]),
		"color": Color(info.color[0], info.color[1], info.color[2], info.color[3])
	}
	var next_color = Color.black;
	if info.has("spawn_on_death"): 
		next_color = load_shapes.info[info.spawn_on_death].color
	enemies[serial_enemy].color = info.color.linear_interpolate(
		next_color, enemies[serial_enemy].hp/info.lives)
	instance.transform.origin = abs_pos(serial_enemy)
	serial_enemy += 1
	

	
func node_from_id (id):
	return get_node(str(id))
	
func abs_pos (id):
	var enemy = enemies[id]
	var from = _path.nodes[enemy.cur].transform.origin
	var to = _path.nodes[enemy.cur+1].transform.origin
	return lerp(from, to, enemy.rel)

func _physics_process(delta):
	var delist = []
	for child in get_children():
		var id = str(child.name).to_int()
		var enemy = enemies[id]
		var info = load_shapes.info[enemy.name]
		
		if enemy.hp <= 0:
			delist.append(id)
			enemy.rel = 0
			for n in range(info.get("spawn_num", 0)):
				# todo rel +- epslion
				spawn(info.spawn_on_death, enemy.cur, enemy.rel - n/10.0)
			continue
		
		enemy.slow_time -= delta
		if enemy.slow_time < 0: enemy.slow_effect = 0
			
		var speed = info.speed * (1-enemy.slow_effect)
		enemy.rel += speed * delta
		while enemy.rel > 1: 
			enemy.rel -= 1
			enemy.cur += 1
		
		var destination = enemy.cur+1
		if destination >= _path.nodes.size():
			delist.append(id)
			enemy.rel = 0
			_resources.lives -= load_shapes.get_damage(enemy.hp, enemy.name)
			continue
			
		child.transform.origin = abs_pos(id)
		
		var axis = Vector3(enemy.axis[0], enemy.axis[1], enemy.axis[2])
		child.transform.basis = child.transform.basis.rotated(axis, delta)
		
		var mesh : MeshInstance = child.get_child(1).get_child(0)
		mesh.get_active_material(0).albedo_color = enemy.color
	
	for id in delist:
		get_node(str(id)).queue_free()
		enemies.erase(id)
		
		if enemies.size() == 0:
			control.end_wave_event()


func damage(name, dam, slow_effect=0, slow_time=0):
	var id = int(name)
	var enemy = enemies[id]
	var info = load_shapes.info[enemy.name]
	
	if enemy.hp > 0:
		if dam > 0:
			enemy.hp -= dam
			_resources.add({ info.resource: dam })
			fx_damage(name)
			var next_color = Color.black;
			if info.has("spawn_on_death"): 
				next_color = load_shapes.info[info.spawn_on_death].color
			enemy.color = info.color.linear_interpolate(next_color, enemy.hp/info.lives)
		if slow_effect > 0:
			enemy.slow_effect = max(slow_effect, enemy.slow_effect)
			enemy.slow_time = slow_time
	
func fx_damage(name):
	var id = int(name)
	var enemy = enemies[id]
	var info = load_shapes.info[enemy.name]
	
	var instance = _fx_enemy_damage.instance()
	_fx_holder.add_child(instance)
	
	var node = node_from_id(id)
	instance.transform = node.transform;
	instance.refresh_basis()
	
	var instance_model = load_shapes.models[info.model_name].instance()
	instance.add_child(instance_model)
	
	instance.refresh_shader(_dissolve_mat.duplicate(), enemy.color)
