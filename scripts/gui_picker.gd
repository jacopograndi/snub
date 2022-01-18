extends Panel

var _hbox : HBoxContainer
var _gui_button : Resource = load("res://scenes/gui/gui_button.tscn")

var _options = []

var gui : Control
var load_turrets : Node
var resources : Node

var hovering = ""

func _fetch ():
	if gui == null: gui = get_parent().gui
	if _hbox == null: _hbox = $Hbox
	
	var root = get_tree().root.get_node("world")
	resources = root.get_node("player").get_node("resources")
	load_turrets = root.get_node("saveload").get_node("load_turrets")
	if !load_turrets.loaded: yield(load_turrets, "done_loading")

func build (options : Array = []):
	_fetch()
	hovering = ""
	
	for child in _hbox.get_children():
		child.disconnect("mouse_entered", self, "_on_gui_turret_mouse_entered")
		child.disconnect("mouse_exited", self, "_on_gui_turret_mouse_exited")
		child.disconnect("pressed", self, "_on_gui_turret_pressed")
		child.queue_free()
	
	_options = options
	for opt in _options:
		var button = _gui_button.instance()
		button.option = opt
		
		if opt.type == "turret buy":
			var tinfo = load_turrets.info[opt.name]
			button.get_node("name").text = tinfo.name
			button.get_node("cash").text = resources.dict_to_str(tinfo.cost)
			button.get_node("texture").texture = load_turrets.thumbnails[tinfo.thumbnail_name]
		if opt.type == "turret upg":
			var tinfo = load_turrets.info[opt.name]
			button.get_node("name").text = tinfo.name
			button.get_node("cash").text = resources.dict_to_str(tinfo.cost)
			button.get_node("texture").texture = load_turrets.thumbnails[tinfo.thumbnail_name]
		if opt.type == "text":
			button.get_node("name").text = opt.name
		if opt.type == "color":
			button.get_node("name").text = ""
			button.get_node("color").color = opt.color
		_hbox.add_child(button)
		
	for child in _hbox.get_children():
		child.connect("mouse_entered", self, "_on_gui_turret_mouse_entered", [child.option])
		child.connect("mouse_exited", self, "_on_gui_turret_mouse_exited", [child.option])
		child.connect("pressed", self, "_on_gui_turret_pressed", [child.option])

func refresh ():
	_fetch()
	
func _on_gui_turret_mouse_entered(option : Dictionary):
	hovering = option.name;
	
func _on_gui_turret_mouse_exited(option : Dictionary):
	hovering = ""
	
func _on_gui_turret_pressed(option : Dictionary):
	gui.control.do(Globals.PlayerActions.PICK, option)
