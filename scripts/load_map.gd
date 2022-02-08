extends Node

var mapname = "map0.json"
var mappath = "./assets/maps/"

var _world : VoxelMesh = null
var _path_holder : Node = null
var _attach_point_holder : Node = null

var saveload : Node = null
var _load_scenes : Node = null

func _ready():
	map_load()

func fetch ():
	var root = get_tree().root.get_node("world")
	if _world == null: 
		_world = root.get_node("world")
	if _path_holder == null: 
		_path_holder = root.get_node("path")
	if _attach_point_holder == null: 
		_attach_point_holder = root.get_node("attach")
	if saveload == null: saveload = root.get_node("saveload")
	if _load_scenes == null: 
		_load_scenes = saveload.get_node("load_scenes")
	
func get_map_state ():
	fetch()
	var state = {}
	
	state["voxels-palette"] = []
	for id in _world.voxel_set.get_ids():
		var col : Color = _world.voxel_set.get_voxel(id).color
		var pal = {
			"color": [ col.r, col.g, col.b, col.a ], 
			"id": id }
		state["voxels-palette"] += [pal]
	
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
	fetch()
	
	_world.erase_voxels()
	
	_world.voxel_set.erase_voxels()
	for vox in state["voxels-palette"]:
		var col = Color(vox.color[0], vox.color[1], vox.color[2], vox.color[3])
		_world.voxel_set.add_voxel({ "color": col })
	
	for vox in state["voxels"]:
		var vecpos = Vector3(vox.pos[0], vox.pos[1], vox.pos[2]);
		_world.set_voxel(vecpos, vox.id)
	_world.update_mesh()
		
	for n in _path_holder.get_children(): n.queue_free()
	
	for pobj in state["path"]:
		var blue = _load_scenes.path
		if "start" in pobj.id:
			blue = _load_scenes.path_start
		if "end" in pobj.id:
			blue = _load_scenes.path_end
		var instance = blue.instance()
		_path_holder.add_child(instance)
		var vecpos = Vector3(pobj.pos[0], pobj.pos[1], pobj.pos[2]);
		instance.transform.origin = vecpos;
		var quat = Quat(pobj.rot[0], pobj.rot[1], pobj.rot[2], pobj.rot[3]);
		instance.transform.basis = Basis(quat);
	
	for n in _attach_point_holder.get_children(): n.queue_free()
	
	for pobj in state["attach"]:
		var blue = _load_scenes.attach_point
		var instance = blue.instance()
		_attach_point_holder.add_child(instance)
		var vecpos = Vector3(pobj.pos[0], pobj.pos[1], pobj.pos[2]);
		instance.transform.origin = vecpos;
		var quat = Quat(pobj.rot[0], pobj.rot[1], pobj.rot[2], pobj.rot[3]);
		instance.transform.basis = Basis(quat);
		
	
func map_save():
	var save_game = File.new()
	save_game.open(mappath+mapname, File.WRITE)
	save_game.store_string(to_json(get_map_state()))
	save_game.close()
	print("saved")

func map_load():
	var save_game = File.new()
	save_game.open(mappath+mapname, File.READ)
	var raw = save_game.get_as_text()
	save_game.close()
	
	var state = parse_json(raw)
	set_map_state(state)
	print("loaded")
	
	_path_holder.refresh_path(false)
	
func map_delete (mapname : String):
	var dir = Directory.new()
	dir.remove(mappath+mapname)
	
func get_mapnames ():
	return saveload.parse_dir(mappath, ".json")


func _process(_delta):
	if Input.is_action_just_released("save"):
		map_save()
	if Input.is_action_just_released("load"):
		#map_load()
		pass
