extends Node

var ineditor = false
var state = Globals.PlayerState.PICK
var statetype = Globals.StateType.TURRET
var selected = ""
var editing_turret = ""

var gui : Node
var wave : Node
var player : Node
var placer : Node
var resources : Node
var pointer : Node
var turret_holder : Node
var enemies_holder : Node
var load_turrets : Node
var saveload_map : Node
var path : Node
var world : VoxelMesh

func fetch ():
	if load_turrets != null: return
	var root = get_tree().root.get_node("world")
	player = root.get_node("player")
	resources = player.get_node("resources")
	placer = player.get_node("placer")
	
	wave = root.get_node("wave")
	pointer = root.get_node("pointer")
	gui = root.get_node("gui")
	world = root.get_node("world")
	path = root.get_node("path")
	turret_holder = root.get_node("turrets")
	enemies_holder = root.get_node("enemies")
	
	var saveload = root.get_node("saveload")
	load_turrets = saveload.get_node("load_turrets")
	saveload_map = saveload.get_node("saveload_map")
	if !load_turrets.loaded: yield(load_turrets, "done_loading")
	
func _ready ():
	fetch()
	_refresh()
	build_option (state, statetype)
	
func build_option (st, sttype):
	var opts = []
	match st:
		Globals.PlayerState.PICK, Globals.PlayerState.PLACE:
			match sttype:
				Globals.StateType.TURRET:
					for t in load_turrets.get_base_turrets():
						opts += [ { "type": "turret buy", "name": t.name } ]
				Globals.StateType.ATTACH:
					opts += [ { "type": "text", "name": "attach" } ]
				Globals.StateType.PATH:
					opts += [ { "type": "text", "name": "start path" } ]
					opts += [ { "type": "text", "name": "path" } ]
					opts += [ { "type": "text", "name": "end path" } ]
				Globals.StateType.VOXEL:
					for i in world.voxel_set.size():
						var details = world.voxel_set.get_voxel(i)
						var color = Color(1, 0, 1)
						if details.has("color"): color = details.color
						opts += [ { "type": "color", "name": str(i), "color": color} ]
						
		Globals.PlayerState.EDIT:
			match sttype:
				Globals.StateType.TURRET:
					var tinfo = turret_holder.get_node(editing_turret).info
					for t in load_turrets.get_upg_turrets(tinfo.name):
						opts += [ { "type": "turret upg", "name": t.name } ]
					if tinfo.has("projectile"):
						opts += [ { "type": "text", "name": "targeting" } ]
					if tinfo.get("modules_max", 0) > 0:
						opts += [ { "type": "text", "name": "modules" } ]
					opts += [ { "type": "text", "name": "sell" } ]
					opts += [ { "type": "text", "name": "back" } ]
					
				Globals.StateType.TARGETING:
					opts += [ { "type": "text", "name": "back" } ]
					
				Globals.StateType.MODULES:
					opts += [ { "type": "text", "name": "back" } ]
					
	gui.bottom_bar.picker.build(opts)
	
func buy (pos, rot, turr_name):
	var info = load_turrets.info[turr_name]
	if resources.greater_than(info.cost):
		resources.sub(info.cost)
		var obj = placer.inst_turret(pos, rot, turr_name)
		editing_turret = obj.name
		state = Globals.PlayerState.EDIT
		build_option(state, statetype)
	else:
		pass
		## TODO feedback
		
func upgrade (turr_inst_name, upg_name):
	var info = load_turrets.info[upg_name]
	if resources.greater_than(info.cost):
		resources.sub(info.cost)
		var prv = turret_holder.get_node(turr_inst_name)
		var pos = prv.transform.origin
		var rot = prv.transform.basis.get_rotation_quat()
		placer.delete(statetype, pos, rot)
		var obj = placer.inst_turret(pos, rot, upg_name)
		editing_turret = obj.name
		state = Globals.PlayerState.EDIT
		build_option(state, statetype)
	else:
		pass
		## TODO feedback
	
func sell (turr_name):
	var turr = turret_holder.get_node(turr_name)
	var info = turr.info
	
	resources.add(info.cost)
	
	placer.delete(Globals.StateType.TURRET, 
		turr.transform.origin, turr.transform.basis.get_rotation_quat())

func _refresh ():
	gui.refresh()
	pointer.refresh(state, statetype, selected)
	
func to_pick ():
	selected = ""
	editing_turret = ""
	state = Globals.PlayerState.PICK
	build_option(state, statetype)

func do (action, par = {}):
	print(str(action) + " " + str(par))
	fetch()
	match state:
		Globals.PlayerState.PICK:
			match action:
				Globals.PlayerActions.PICK:
					selected = par.name
					state = Globals.PlayerState.PLACE
					
				Globals.PlayerActions.SELECT:
					match statetype:
						Globals.StateType.TURRET:
							selected = ""
							editing_turret = par.selected
							state = Globals.PlayerState.EDIT
							build_option(state, statetype)
						_: to_pick()
					
				Globals.PlayerActions.CHANGE_TYPE:
					selected = ""
					editing_turret = ""
					state = Globals.PlayerState.PICK
					statetype = par.statetype
					build_option(state, statetype)
					
		Globals.PlayerState.PLACE:
			match action:
				Globals.PlayerActions.PLACE:
					match statetype:
						Globals.StateType.TURRET:
							buy(par.pos, par.rot, selected)
						Globals.StateType.ATTACH:
							placer.inst_attach(par.pos, par.rot)
						Globals.StateType.PATH:
							match selected:
								"start path": placer.inst_path_start(par.pos, par.rot)
								"path": placer.inst_path(par.pos, par.rot)
								"end path": placer.inst_path_end(par.pos, par.rot)
						Globals.StateType.VOXEL:
							placer.inst_voxel(par.pos, par.rot, selected)
							
				Globals.PlayerActions.PICK:
					selected = par.name
							
				Globals.PlayerActions.DELETE: 
					placer.delete(statetype, par.pos, par.rot)
					
				Globals.PlayerActions.CANCEL: to_pick()
					
				Globals.PlayerActions.CHANGE_TYPE:
					selected = ""
					editing_turret = ""
					state = Globals.PlayerState.PICK
					statetype = par.statetype
					build_option(state, statetype)
					
		Globals.PlayerState.EDIT:
			match action:
				Globals.PlayerActions.PICK:
					match statetype:
						Globals.StateType.TURRET:
							selected = par.name
							match par.type:
								"turret upg":
									upgrade(editing_turret, par.name)
								_ :
									match par.name:
										"targeting": 
											statetype = Globals.StateType.TARGETING
											build_option(state, statetype)
										"modules": 
											statetype = Globals.StateType.MODULES
											build_option(state, statetype)
										"sell": 
											sell(editing_turret)
											to_pick()
										"back": to_pick()
									
						Globals.StateType.TARGETING:
							selected = par.name
							match par.name:
								"back": 
									statetype = Globals.StateType.TURRET
									build_option(state, statetype)
									
						Globals.StateType.MODULES:
							selected = par.name
							match par.name:
								"back": 
									statetype = Globals.StateType.TURRET
									build_option(state, statetype)
								
						_: to_pick() 
							
				Globals.PlayerActions.CANCEL: to_pick()
					
				Globals.PlayerActions.CHANGE_TYPE:
					selected = ""
					editing_turret = ""
					state = Globals.PlayerState.PICK
					statetype = par.statetype
					build_option(state, statetype)
	_refresh()
	

func gui_editor_toggle_event ():
	ineditor = !ineditor
	if !ineditor: 
		statetype = Globals.StateType.TURRET
		to_pick()
	
	gui.refresh()
	path.refresh_path(ineditor)
	
func gui_start_wave_event ():
	if wave.ongoing: return
	path.refresh_path(ineditor)
	wave.start()
	gui.refresh()
	
func gui_save_map_event (): saveload_map.map_save()

func gui_save_as_map_event (mapname : String):
	saveload_map.mapname = mapname
	saveload_map.map_save()
	
func gui_delete_map_event (mapname : String):
	saveload_map.map_delete(mapname)
	
func gui_change_map_event (mapname : String):
	saveload_map.mapname = mapname
	saveload_map.map_load()
	gui.load_map.visible = false
	
	path.refresh_path(ineditor)
	gui.refresh()
