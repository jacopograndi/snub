extends PanelContainer

var hbox_labels 
var hbox_global
var _turret_holder : Node
var load_turrets : Node
var resources : Node

var gui : Control

func _fetch ():
	if gui == null: gui = get_parent()
	if load_turrets != null: return;
	
	var root = get_tree().root.get_node("world")
	_turret_holder = root.get_node("turrets")
	
	hbox_labels = $"vbox/hbox_global/hbox_labels"
	hbox_global = $"vbox/hbox_global"
	
	resources = root.get_node("player").get_node("resources")
	
	load_turrets = root.get_node("saveload").get_node("load_turrets")
	if !load_turrets.loaded: yield(load_turrets, "done_loading")
	
	
func flatten (dict : Dictionary):
	var flat = {}
	for k in dict:
		if dict[k] is Dictionary:
			for kk in dict[k]:
				flat[k+" "+kk] = dict[k][kk]
		else: flat[k] = dict[k]
	return flat

func refresh (turret_info : Dictionary, comp : Dictionary = {}):
	_fetch()
	
	get_node("vbox").get_node("name_label").text = "name: " + turret_info.name

	var base_labels = hbox_global.get_node("hbox_labels")
	var base_values = hbox_global.get_node("hbox_values")
	var base_cmp = hbox_global.get_node("hbox_cmp")
	for child in base_labels.get_children(): child.queue_free()
	for child in base_values.get_children(): child.queue_free()
	for child in base_cmp.get_children(): child.queue_free()
	
	var flat = flatten(turret_info)
	var flat_comp = flatten(comp)
	
	var skip = ["upgrades"]
	for k in flat:
		if k in skip or "name" in k: continue
		
		var label_lab = Label.new() 
		label_lab.text = k
		base_labels.add_child(label_lab)
		
		var val = str(flat[k])
		var label_val = Label.new() 
		label_val.text = val
		base_values.add_child(label_val)
		
		var cmp_val = str(flat_comp.get(k, ""))
		if (cmp_val == val): cmp_val = ""
		var label_cmp = Label.new() 
		label_cmp.text = cmp_val
		base_cmp.add_child(label_cmp)

func _process(delta):
	_fetch()
	
	var info = null;
	var comp = {};
	
	var hovering = null
	if gui.control.state == Globals.PlayerState.PICK and \
			gui.control.statetype == Globals.StateType.TURRET and \
			gui.bottom_bar.picker.hovering != "":
		hovering = gui.bottom_bar.picker.hovering
		
	var highlight = null
	if gui.control.state == Globals.PlayerState.EDIT and \
			(gui.control.statetype == Globals.StateType.TURRET or \
			gui.control.statetype == Globals.StateType.MODULES or \
			gui.control.statetype == Globals.StateType.MODULES_PICK):
		var turret_name = gui.control.editing_turret
		highlight = _turret_holder.get_node(turret_name)
		
	var placing = null
	if gui.control.state == Globals.PlayerState.PLACE and \
			gui.control.statetype == Globals.StateType.TURRET and \
			gui.control.selected != "":
		placing = gui.control.selected
		
	if highlight != null:
		info = highlight.info_mod
		
		var opts = ["back", "targeting", "modules", "sell", "add"]
		if gui.control.state == Globals.PlayerState.EDIT and \
				gui.control.statetype == Globals.StateType.TURRET and \
				gui.bottom_bar.picker.hovering != "" and \
				not gui.bottom_bar.picker.hovering in opts:
			comp = load_turrets.info[gui.bottom_bar.picker.hovering]
			
		elif gui.control.state == Globals.PlayerState.EDIT and \
				gui.control.statetype == Globals.StateType.MODULES_PICK and \
				gui.bottom_bar.picker.hovering != "" and \
				not gui.bottom_bar.picker.hovering in opts:
			comp = highlight.make_info_mod(highlight.modules + [gui.bottom_bar.picker.hovering])
			
	elif placing != null:
		info = load_turrets.info[placing]
	elif hovering != null:
		info = load_turrets.info[hovering]
	elif gui.player.placer.colliding \
			and "turrets" in gui.player.placer.colliding_group:
		info = gui.player.placer.colliding_node.info
		
	if info != null: 
		refresh(info, comp)
		self.visible = true
	else: self.visible = false
