extends KinematicBody

var vel = Vector3()
var rot = Quat()
var rotx = Quat()
var roty = Quat()

var sensitivity_mouse = 0.1

var ray

var _normal = Vector3.ZERO
var _colliding = false
var _colliding_group = []
var _colliding_node

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
	ray = find_node("RayCast")
	
	ray.enabled = true
	ray.collide_with_areas = false
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
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

func _load():
	var save_game = File.new()
	save_game.open("user://map0.json", File.READ)
	var raw = save_game.get_as_text()
	save_game.close()
	
	print(raw)
	var state = parse_json(raw)
	set_map_state(state)

func _process(delta):
	if Input.is_action_just_released("save"):
		_save()
	if Input.is_action_just_released("load"):
		_load()
		
func clear_children (node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func _move_input(delta):
	var dir = Vector3()
	
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
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	dir = rot * input_movement_vector
	
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
			
	if "path" in sel_map[sel]:
		ray.collision_mask = 3
	else: 
		ray.collision_mask = 1
	
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
	
func place_turret ():
	var ptr = self.get_parent().find_node("pointer");
	if Input.is_action_just_pressed("use"):
		if _colliding && "attach" in _colliding_group:
			if !check_overlap_pointer():
				var instance = _turret.instance()
				_turret_holder.add_child(instance)
				instance.transform.origin = ptr.transform.origin;
				instance.transform.basis = Basis(ptr.transform.basis.get_rotation_quat());
				instance.refresh_normal()
				var instance_model = _turret_blues[0].instance()
				instance_model.name = "model"
				instance.add_child(instance_model)
				instance.refresh_model()
				
	if Input.is_action_just_pressed("cancel"):
		if _colliding && "turrets" in _colliding_group:
			_colliding_node.queue_free()
			
func place_start_path ():
	var ptr = self.get_parent().find_node("pointer");
	if Input.is_action_just_pressed("use"):
		if _colliding && "voxels" in _colliding_group:
			if !check_overlap_pointer():
				var instance = _path_start.instance()
				_path_holder.add_child(instance)
				instance.transform.origin = ptr.transform.origin + _normal * 0.25;
				instance.transform.basis = Basis(ptr.transform.basis.get_rotation_quat());
				
	if Input.is_action_just_pressed("cancel"):
		if _colliding && "path" in _colliding_group:
			_colliding_node.queue_free()
			
func place_path ():
	var ptr = self.get_parent().find_node("pointer");
	if Input.is_action_just_pressed("use"):
		if _colliding && "path" in _colliding_group:
			if !check_overlap_pointer():
				var instance = _path.instance()
				_path_holder.add_child(instance)
				instance.transform.origin = ptr.transform.origin + _normal * 0.25;
				instance.transform.basis = Basis(ptr.transform.basis.get_rotation_quat());
				instance.set_name("path")
				
				_colliding_node.transform.basis = Basis(ptr.transform.basis.get_rotation_quat());
				
	if Input.is_action_just_pressed("cancel"):
		if _colliding && "path" in _colliding_group:
			_colliding_node.queue_free()
			
func place_path_end ():
	var ptr = self.get_parent().find_node("pointer");
	if Input.is_action_just_pressed("use"):
		if _colliding && "path" in _colliding_group:
			if !check_overlap_pointer():
				var instance = _path_end.instance()
				_path_holder.add_child(instance)
				instance.transform.origin = ptr.transform.origin + _normal * 0.25
				instance.transform.basis = Basis(ptr.transform.basis.get_rotation_quat());
		
	if Input.is_action_just_pressed("cancel"):
		if _colliding && "path" in _colliding_group:
			_colliding_node.queue_free()
				
func place_attach ():
	var ptr = self.get_parent().find_node("pointer");
	if Input.is_action_just_pressed("use"):
		if _colliding && "voxels" in _colliding_group:
			if !check_overlap_pointer():
				var instance = _attach_point.instance()
				_attach_point_holder.add_child(instance)
				instance.transform.origin = ptr.transform.origin;
				instance.transform.basis = Basis(ptr.transform.basis.get_rotation_quat());
		
	if Input.is_action_just_pressed("cancel"):
		if _colliding && "attach" in _colliding_group:
			_colliding_node.queue_free()
	
func _pointer ():
	var ptr = self.get_parent().find_node("pointer");
	
	match sel:
		0:
			place_turret()
		1:
			place_start_path()
		2:
			place_path()
		3:
			place_path_end()
		4:
			place_attach()
	
	var from = self.transform.origin
	var to = from + (rot * Vector3.FORWARD) * 5
	
	ptr.transform.origin = to
	
	if ray.is_colliding():
		_colliding = true
		_normal = ray.get_collision_normal().normalized();
		var pos = ray.get_collision_point()
		
		var node = ray.get_collider().get_parent()
		_colliding_node = node
		_colliding_group = node.get_groups()
		
		if ("voxels" in _colliding_group or "path" in _colliding_group):
			var _cursor_position = ray.get_collision_point() - _normal * (0.5 / 2)
			var tran = 0.5 *_cursor_position
			tran += Vector3.ONE * (0.5 / 2) + _normal* (0.5 / 2)
			pos = tran
		
		if ("attach" in _colliding_group):
			pos = node.global_transform.origin;
			_normal = (node.global_transform.basis.get_rotation_quat() * Vector3.UP).normalized();
		
		ptr.transform.basis = Basis(Utils.quat_look(_normal, Vector3.UP))
		ptr.transform.origin = pos
	else:
		_colliding = false
		_colliding_group = []

func _input(event):
	if event is InputEventMouseMotion:
		var mouse = Vector2(
			deg2rad(event.relative.x) * -1, 
			deg2rad(event.relative.y) * -1)
		mouse *= sensitivity_mouse
		rotx *= Quat(Vector3(0, mouse.x, 0))
		roty *= Quat(Vector3(mouse.y, 0, 0))
		
		rot = (rotx * roty).normalized()
		self.transform.basis = Basis(rot)
