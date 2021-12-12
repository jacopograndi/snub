extends KinematicBody

var vel = Vector3()

var _mouse = Vector2()
var sensitivity_mouse = 0.1

var _camera : Camera

var _normal = Vector3.ZERO
var _colliding = false
var _colliding_group = []
var _colliding_node
var _collision_point

var _pivot
var _pivot_dist
var _pivot_rot
var _pivot_look

var _world

var _turret : PackedScene
var _turret_holder
var _turret_blues = []

var _attach_point
var _attach_point_holder

var _path_start
var _path
var _path_end
var _path_holder

var sel = 0;
var sel_map = [ 
	"turrets", "path start", "path", "path end", "attach point"
]

func _ready():	
	_camera = $Camera
	
	_world = self.get_parent().find_node("world")
	_turret_holder = self.get_parent().find_node("turrets")
	_path_holder = self.get_parent().find_node("path")
	_attach_point_holder = self.get_parent().find_node("attach")
	
	_turret = load("res://scenes/turret.tscn")
	_path_start = load("res://scenes/path_start.tscn")
	_path = load("res://scenes/path.tscn")
	_path_end = load("res://scenes/path_end.tscn")
	_attach_point = load("res://scenes/attach_point.tscn")
	
	load_turrets()
	
	#_save()
	_load()

func load_turrets():
	_turret_blues = []
	var dir = Directory.new()
	dir.open("res://models/turrets")
	dir.list_dir_begin(true)
	var turr = dir.get_next()
	while turr != "":
		if (turr.ends_with(".glb")):
			_turret_blues.append(load("res://models/turrets/" + turr))
		turr = dir.get_next()

func get_map_state ():
	var state = {}
	
	state["voxels"] = []
	for pos in _world.get_voxels():
		var vox = { "pos": [pos.x, pos.y, pos.z], "id":_world.get_voxel_id(pos) }
		state["voxels"] += [vox]

	state["path"] = []
	for node in _path_holder.get_children():
		var pos = node.transform.origin;
		var rot = node.transform.basis.get_rotation_quat();
		var pobj = { 
			"pos": [pos.x, pos.y, pos.z], 
			"rot": [rot.x, rot.y, rot.z, rot.w], 
			"id": node.name
		}
		state["path"] += [pobj]

	state["attach"] = []
	for node in _attach_point_holder.get_children():
		var pos = node.transform.origin;
		var rot = node.transform.basis.get_rotation_quat();
		var pobj = { 
			"pos": [pos.x, pos.y, pos.z], 
			"rot": [rot.x, rot.y, rot.z, rot.w], 
			"id": node.name
		}
		state["attach"] += [pobj]
		
	return state
	
func set_map_state (state):
	_world.erase_voxels()
	for vox in state["voxels"]:
		var vecpos = Vector3(vox.pos[0], vox.pos[1], vox.pos[2]);
		_world.set_voxel(vecpos, vox.id)
	_world.update_mesh()
	
	clear_children(_path_holder)
	for pobj in state["path"]:
		var blue = _path
		if "start" in pobj.id:
			blue = _path_start
		if "end" in pobj.id:
			blue = _path_end
		var instance = blue.instance()
		_path_holder.add_child(instance)
		var vecpos = Vector3(pobj.pos[0], pobj.pos[1], pobj.pos[2]);
		instance.transform.origin = vecpos;
		var quat = Quat(pobj.rot[0], pobj.rot[1], pobj.rot[2], pobj.rot[3]);
		instance.transform.basis = Basis(quat);
	
	clear_children(_attach_point_holder)
	for pobj in state["attach"]:
		var blue = _attach_point
		var instance = blue.instance()
		_attach_point_holder.add_child(instance)
		var vecpos = Vector3(pobj.pos[0], pobj.pos[1], pobj.pos[2]);
		instance.transform.origin = vecpos;
		var quat = Quat(pobj.rot[0], pobj.rot[1], pobj.rot[2], pobj.rot[3]);
		instance.transform.basis = Basis(quat);
		
	
func _save():
	var save_game = File.new()
	save_game.open("user://map0.json", File.WRITE)
	save_game.store_string(to_json(get_map_state()))
	save_game.close()
	print("saved")

func _load():
	var save_game = File.new()
	save_game.open("user://map0.json", File.READ)
	var raw = save_game.get_as_text()
	save_game.close()
	
	var state = parse_json(raw)
	set_map_state(state)
	print("loaded")

func _process(delta):
	if Input.is_action_just_released("save"):
		_save()
	if Input.is_action_just_released("load"):
		_load()
		
func clear_children (node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func look_free (delta, m):
	self.transform.basis = self.transform.basis.rotated(Vector3.UP, m.x)
	var rrrot = self.transform.basis.get_rotation_quat()
	self.transform.basis = self.transform.basis.rotated(rrrot*Vector3.RIGHT, m.y)
	
func look_orbit(delta, m):
	var diff : Vector3 = self.transform.origin - _pivot
	var orbit : Basis = Transform.looking_at(diff, Vector3.UP).basis
	orbit = orbit.rotated(Vector3.UP, m.x)
	orbit = orbit.rotated(orbit.get_rotation_quat()*Vector3.RIGHT, -m.y)
	self.transform.basis = self.transform.basis.rotated(Vector3.UP, m.x)
	var rrrot = self.transform.basis.get_rotation_quat()
	self.transform.basis = self.transform.basis.rotated(rrrot*Vector3.RIGHT, m.y)
	
	var normdiff = diff.normalized()
	self.transform.origin = _pivot - orbit.z * _pivot_dist

func _move_input(delta):
	var dir = Vector3()
		
	var m = _mouse
	_mouse = Vector2()
	
	var orbiting = false

	if Input.is_action_just_pressed("orbit"):
		if _colliding:
			_pivot = _collision_point
			var diff : Vector3 = self.transform.origin - _pivot
			_pivot_rot = Transform.looking_at(diff, Vector3.UP).basis.get_rotation_quat()
			_pivot_dist = diff.length()
			_pivot_look = Transform(Basis(), _collision_point)
		else: _pivot = null
		
	if Input.is_action_pressed("orbit"):
		if _pivot != null:
			orbiting = true
			look_orbit(delta, m)
		else:
			look_free(delta, m)
		
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.is_action_pressed("look"):
		look_free(delta, m)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	var input_movement_vector = Vector3()
	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.z -= 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.z += 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1
	if Input.is_action_pressed("movement_up"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_down"):
		input_movement_vector.y -= 1
	input_movement_vector = input_movement_vector.normalized()
	
	dir = self.transform.basis.get_rotation_quat() * input_movement_vector
	
	vel += dir * delta;
	vel *= 0.8
	
	var collision = self.move_and_collide(vel)
	if collision: vel = Vector3(0, 0, 0)

func _physics_process(delta):
	if Input.is_action_just_released("cycle_forward"):
		sel += 1
		if sel >= len(sel_map):
			sel = len(sel_map)-1
	if Input.is_action_just_released("cycle_backward"):
		sel -= 1
		if sel < 0:
			sel = 0
			
	_move_input(delta)
	_pointer()
	
func check_overlap_pointer():
	var ptr = self.get_parent().find_node("pointer");
	
	var overlap = false
	var space = get_world().direct_space_state

	var center = ptr.transform.origin + _normal*0.25
	
	var shape: = BoxShape.new()
	shape.extents = Vector3(0.24, 0.24, 0.24)
	
	var params: = PhysicsShapeQueryParameters.new()
	params.set_shape(shape)
	params.collision_mask = 3
	params.transform = Transform.IDENTITY
	params.transform.origin = center
	
	var result = space.intersect_shape(params)
	for body in result:
		if !body.collider.get_parent().is_in_group("attach"): 
			overlap = true
			break
	
	for pos in _world.get_voxels():
		var wpos = pos * 0.5
		wpos += Vector3.ONE * (0.5 / 2)
		var dist = (wpos - center).length_squared()
		if dist < 0.1:
			overlap = true
			break
			
	for node in _path_holder.get_children():
		var pos = node.transform.origin
		var dist = (pos - center).length_squared()
		if dist < 0.1:
			overlap = true
			break
			
	return overlap
	
func _inst_turret (pos, rot):
	var instance = _turret.instance()
	_turret_holder.add_child(instance)
	instance.transform.origin = pos;
	instance.transform.basis = Basis(rot);
	instance.refresh_normal()
	var instance_model = _turret_blues[0].instance()
	instance_model.name = "model"
	instance.add_child(instance_model)
	instance.refresh_model()
	
func _inst_path_start (pos, rot):
	var instance = _path_start.instance()
	_path_holder.add_child(instance)
	instance.transform.origin = pos + _normal * 0.25;
	instance.transform.basis = Basis(rot);
	
func _inst_path (pos, rot):
	var instance = _path.instance()
	_path_holder.add_child(instance)
	instance.transform.origin = pos + _normal * 0.25;
	instance.transform.basis = Basis(rot);
	instance.set_name("path")
	_colliding_node.transform.basis = Basis(rot);
	
func _inst_path_end (pos, rot):
	var instance = _path_end.instance()
	_path_holder.add_child(instance)
	instance.transform.origin = pos + _normal * 0.25
	instance.transform.basis = Basis(rot);
	
func _inst_attach (pos, rot):
	var instance = _attach_point.instance()
	_attach_point_holder.add_child(instance)
	instance.transform.origin = pos;
	instance.transform.basis = Basis(rot);
	
func place (group, inst : FuncRef):
	var ptr = self.get_parent().find_node("pointer");
	if Input.is_action_just_pressed("use"):
		if _colliding && group in _colliding_group:
			if !check_overlap_pointer():
				inst.call_func(ptr.transform.origin, ptr.transform.basis.get_rotation_quat())
				
func delete (group):
	if Input.is_action_just_pressed("cancel"):
		if _colliding && group in _colliding_group:
			_colliding_node.queue_free()
	
func _pointer ():
	var ptr = self.get_parent().find_node("pointer");
	
	var space: PhysicsDirectSpaceState = get_world().direct_space_state as PhysicsDirectSpaceState
	var mouse2d = get_viewport().get_mouse_position()
	var from = _camera.project_ray_origin(mouse2d)
	var to = (from + _camera.project_ray_normal(mouse2d) * 5)
	
	ptr.transform.origin = to
	
	var mask = 1
	if sel in [1, 2, 3]: mask = 3 
	var result = space.intersect_ray(from, to, [], mask)
	if result.size() > 0:
		ptr.get_child(0).visible = true
		
		_colliding = true
		_normal = result.normal;
		_collision_point = result.position
		
		var node = result.collider.get_parent()
		_colliding_node = node
		_colliding_group = node.get_groups()
		
		if ("voxels" in _colliding_group or "path" in _colliding_group):
			var cpos = result.position - _normal * (0.5 / 2)
			var _cursor_position = (cpos / 0.5).floor() * 0.5
			_cursor_position += Vector3.ONE * (0.5 / 2) + _normal * (0.5 / 2)
			_collision_point = _cursor_position
		
		if ("attach" in _colliding_group):
			_collision_point = node.global_transform.origin;
			_normal = (node.global_transform.basis.get_rotation_quat() * Vector3.UP).normalized();
		
		ptr.transform.basis = Basis(Utils.quat_look(_normal, Vector3.UP))
		ptr.transform.origin = _collision_point
	else:
		_colliding = false
		_colliding_group = []
		ptr.get_child(0).visible = false
	
	match sel:
		0:
			place("attach", funcref(self, "_inst_turret"))
			delete("turret")
		1:
			place("voxels", funcref(self, "_inst_path_start"))
			delete("path")
		2:
			place("path", funcref(self, "_inst_path"))
			delete("path")
		3:
			place("path", funcref(self, "_inst_path_end"))
			delete("path")
		4:
			place("voxels", funcref(self, "_inst_attach"))
			delete("attach")

func _input(event):
	if event is InputEventMouseMotion:
		_mouse += Vector2(
			deg2rad(event.relative.x) * -1, 
			deg2rad(event.relative.y) * -1) * sensitivity_mouse
