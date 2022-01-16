extends Panel

var hbox_labels 
var hbox_global
var _turret_holder : Node
var _turret_values : Resource = load("res://scenes/gui/gui_turret_values.tscn")
var load_turrets : Node

var gui : Control

func _fetch ():
	if gui == null: gui = get_parent()
	if load_turrets != null: return;
	
	var root = get_tree().root.get_node("world")
	_turret_holder = root.get_node("turrets")
	
	hbox_labels = $"hbox_global/hbox_labels"
	hbox_global = $"hbox_global"
	
	load_turrets = root.get_node("saveload").get_node("load_turrets")
	if !load_turrets.loaded: yield(load_turrets, "done_loading")
	
	
func refresh (turret : Dictionary, upgraded : Dictionary = {}):
	_fetch()
	if upgraded == null: rect_min_size.x = 200
	else: rect_min_size.x = 230
	
	get_node("name_label").text = "name: " + turret.name
	
	var dict = {
		"damage": turret.get("damage", "-"),
		"range": turret.get("range", "-"),
		"turn speed": turret.get("turn_speed", "-"),
		"cooldown": turret.get("cooldown", "-"),
		"projectile": turret.get("projectile", {}).get("type", "-"),
		"spread": turret.get("projectile", {}).get("spread", "-"),
		"projectile speed": turret.get("projectile", {}).get("speed", "-"),
		"projectiles per shot": turret.get("projectile", {}).get("amount", "-"),
		"modules": turret.get("modules_max", "-"),
	}

	var base_values = hbox_global.get_node("hbox_values")
	for k in dict:
		base_values.get_node(k).text = str(dict[k]);

func _process(delta):
	_fetch()
	
	var info = null;
	
	var hovering = null
	if gui.control.state == Globals.PlayerState.PICK and \
			gui.control.statetype == Globals.StateType.TURRET and \
			gui.bottom_bar.picker.hovering != "":
		hovering = gui.bottom_bar.picker.hovering
		
	var highlight = null
	if gui.control.state == Globals.PlayerState.EDIT and \
			gui.control.statetype == Globals.StateType.TURRET:
		var turret_name = gui.control.editing_turret
		highlight = _turret_holder.get_node(turret_name)
		
	var placing = null
	if gui.control.state == Globals.PlayerState.PLACE and \
			gui.control.statetype == Globals.StateType.TURRET and \
			gui.control.selected != "":
		placing = gui.control.selected
		
	if highlight != null:
		info = highlight.info
	elif placing != null:
		info = load_turrets.info[placing]
	elif hovering != null:
		info = load_turrets.info[hovering]
	elif gui.player.placer.colliding \
			and "turrets" in gui.player.placer.colliding_group:
		info = gui.player.placer.colliding_node.info
		
	if info != null: 
		refresh(info)
		self.visible = true
	else: self.visible = false
