extends Spatial

var player : Spatial
var world : VoxelMesh
var turret_holder : Node
var path_holder : Node
var attach_point_holder : Node
var load_turrets : Node
var saveload_map : Node
var load_scenes : Node
var ptr : Spatial
var resources : Node

var normal = Vector3.ZERO
var colliding = false
var colliding_group = []
var colliding_node : Spatial
var collision_point : Vector3

func _ready ():
	player = get_parent()
	resources = get_parent().get_node("resources")
	
	var root = get_tree().root.get_child(0)
	world = root.get_node("world")
	turret_holder = root.get_node("turrets")
	attach_point_holder = root.get_node("attach")
	path_holder = root.get_node("path")
	ptr = root.find_node("pointer");
	
	var saveload = root.get_node("saveload")
	load_turrets = saveload.get_node("load_turrets")
	saveload_map = saveload.get_node("saveload_map")
	load_scenes = saveload.get_node("load_scenes")
	
	if !load_turrets.loaded: yield(load_turrets, "done_loading")

func _physics_process(_delta):
	_pointer()

func check_overlap_pointer():
	var overlap = false
	var space = get_world().direct_space_state

	var center = ptr.transform.origin + normal*0.25
	
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
	
	for pos in world.get_voxels():
		var wpos = pos * 0.5
		wpos += Vector3.ONE * (0.5 / 2)
		var dist = (wpos - center).length_squared()
		if dist < 0.1:
			overlap = true
			break
			
	for node in path_holder.get_children():
		var pos = node.transform.origin
		var dist = (pos - center).length_squared()
		if dist < 0.1:
			overlap = true
			break
			
	return overlap
	
func _inst_turret (pos, rot):
	var instance = load_scenes.turret.instance()
	turret_holder.add_child(instance)
	instance.transform.origin = pos;
	instance.transform.basis = Basis(rot);
	instance.refresh_normal()
	
	var info = load_turrets.info[player.sel.name]
	var model = load_turrets.models[info.model_name]
	var instance_model = model.instance()
	instance_model.name = "model"
	instance.add_child(instance_model)
	instance.refresh_model()
	
	instance.refresh_info(info)
	
func _inst_path_start (pos, rot):
	var instance = load_scenes.path_start.instance()
	path_holder.add_child(instance)
	instance.transform.origin = pos + normal * 0.25;
	instance.transform.basis = Basis(rot);
	
func _inst_path (pos, rot):
	var instance = load_scenes.path.instance()
	path_holder.add_child(instance)
	instance.transform.origin = pos + normal * 0.25;
	instance.transform.basis = Basis(rot);
	instance.set_name("path")
	colliding_node.transform.basis = Basis(rot);
	
func _inst_path_end (pos, rot):
	var instance = load_scenes.path_end.instance()
	path_holder.add_child(instance)
	instance.transform.origin = pos + normal * 0.25
	instance.transform.basis = Basis(rot);
	
func _inst_attach (pos, rot):
	var instance = load_scenes.attach_point.instance()
	attach_point_holder.add_child(instance)
	instance.transform.origin = pos;
	instance.transform.basis = Basis(rot);
	
func place (group, inst : FuncRef):
	if Input.is_action_just_pressed("use"):
		if colliding && group in colliding_group:
			if !check_overlap_pointer():
				inst.call_func(ptr.transform.origin, ptr.transform.basis.get_rotation_quat())
				return "ok"
	
func delete (group):
	if Input.is_action_just_pressed("cancel"):
		if colliding && group in colliding_group:
			colliding_node.queue_free()
			
func select ():
	pass
	
func _pointer ():
	if player.sel.name == "" or player.sel.type == "": ptr.visible = false
	else: ptr.visible = true
	
	var space: PhysicsDirectSpaceState = get_world().direct_space_state as PhysicsDirectSpaceState
	var mouse2d = get_viewport().get_mouse_position()
	var from = player.camera.project_ray_origin(mouse2d)
	var to = (from + player.camera.project_ray_normal(mouse2d) * 100)
	
	ptr.transform.origin = to
	
	var mask = 1
	if player.sel.name.find("path") != -1: mask = 3 
	
	var result = space.intersect_ray(from, to, [], mask)
	if result.size() > 0:
		ptr.visible = true
		
		colliding = true
		normal = result.normal;
		collision_point = result.position
		
		var node = result.collider.get_parent()
		colliding_node = node
		colliding_group = node.get_groups()
		
		if ("voxels" in colliding_group or "path" in colliding_group):
			var cpos = result.position - normal * (0.5 / 2)
			var cursor_position = (cpos / 0.5).floor() * 0.5
			cursor_position += Vector3.ONE * (0.5 / 2) + normal * (0.5 / 2)
			collision_point = cursor_position
		
		if ("attach" in colliding_group):
			collision_point = node.global_transform.origin;
			normal = (node.global_transform.basis.get_rotation_quat() * Vector3.UP).normalized();
		
		ptr.transform.basis = Basis(Utils.quat_look(normal, Vector3.UP))
		ptr.transform.origin = collision_point
	else:
		colliding = false
		colliding_group = []
		ptr.visible = false
	
	var placed = ""
	match player.sel.type:
		"map_tools":
			match player.sel.name:
				"start path":
					place("path", funcref(self, "_inst_path_start"))
					delete("path")
				"path":
					place("path", funcref(self, "_inst_path"))
					delete("path")
				"end path":
					place("path", funcref(self, "_inst_path_end"))
					delete("path")
				"attach":
					place("voxels", funcref(self, "_inst_attach"))
					delete("attach")
		"voxels":
			pass
		"turrets":
			placed = place("attach", funcref(self, "_inst_turret"))
			if placed == "ok" and !player.in_editor:
				resources.sub(load_turrets.info[player.sel.name].cost)
			delete("turret")
	
	if placed == "ok":
		player.sel.name = ""
		player.sel.type = ""
		if ptr.has_node("preview"):
			ptr.get_node("preview").queue_free()
		player.refresh_gui()
	else:
		select()
