extends Spatial

var load_turrets : Node

func fetch ():
	if load_turrets != null: return
	var root = get_tree().root.get_node("world")
	
	load_turrets = root.get_node("saveload").get_node("load_turrets")
	if !load_turrets.loaded: yield(load_turrets, "done_loading")

func refresh (state, statetype, turret_name : String = ""):
	fetch()
	for child in get_children():
		if child.name != "base": child.queue_free();
	get_node("base").visible = false
	
	if state == Globals.PlayerState.PLACE:
		if statetype == Globals.StateType.TURRET:
			if turret_name != "":
				var info = load_turrets.info[turret_name]
				var model = load_turrets.models[info.model_name]
				var instance_model = model.instance()
				instance_model.name = "preview"
				add_child(instance_model)
				get_node("base").visible = false
		else:
			get_node("base").visible = true
