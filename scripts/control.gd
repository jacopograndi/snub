extends Node

var ineditor = false
var state = Globals.PlayerState.PICK
var statetype = Globals.StateType.TURRET
var selected = ""
var editing_turret = ""

var gui : Node
var pointer : Node
var turret_holder : Node
var load_turrets : Node
var path : Node
var world : VoxelMesh

func fetch ():
	if load_turrets != null: return
	var root = get_tree().root.get_node("world")
	gui = root.get_node("gui")
	pointer = root.get_node("pointer")
	world = root.get_node("world")
	path = root.get_node("path")
	turret_holder = root.get_node("turrets")
	var saveload = root.get_node("saveload")
	load_turrets = saveload.get_node("load_turrets")
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
						if details.has("color"):
							color = details.color
						opts += [ { "type": "color", "name": i, "color": color} ]
						
		Globals.PlayerState.EDIT:
			match sttype:
				Globals.StateType.TURRET:
					var tname = turret_holder.get_node(editing_turret).info.name
					for t in load_turrets.get_upg_turrets(tname):
						opts += [ { "type": "turret upg", "name": t.name } ]
					opts += [ { "type": "text", "name": "sell" } ]
					opts += [ { "type": "text", "name": "priority" } ]
					opts += [ { "type": "text", "name": "modules" } ]
					opts += [ { "type": "text", "name": "back" } ]
					
	gui.bottom_bar.picker.build(opts)

func _refresh ():
	gui.refresh(ineditor)
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
					selected = par.selected
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
							editing_turret = par.placed
							state = Globals.PlayerState.EDIT
							build_option(state, statetype)
							
				Globals.PlayerActions.DELETE: pass
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
							selected = par.selected
							match par.selected:
								"back": 
									to_pick()
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
	gui.refresh(ineditor)
	path.refresh_path(ineditor)
	
func gui_start_wave_event ():
	path.refresh_path(ineditor)
	#_enemies.spawn()
	gui.refresh(ineditor)
