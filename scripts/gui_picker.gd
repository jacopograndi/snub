extends Panel

var _hbox : HBoxContainer
var _gui_button : Resource = load("res://scenes/gui/gui_button.tscn")

var _options = []

var thumbs_generic = {}

var gui : Control
var saveload : Node
var load_turrets : Node
var resources : Node

var hovering = ""

func _fetch ():
	if gui == null: gui = get_parent().gui
	if _hbox == null: _hbox = $Hbox
	
	var root = get_tree().root.get_node("world")
	resources = root.get_node("player").get_node("resources")
	saveload = root.get_node("saveload")
	load_turrets = saveload.get_node("load_turrets")
	load_thumbnails()
	if !load_turrets.loaded: yield(load_turrets, "done_loading")
	

func load_thumbnails():
	var thumbspath = "res://assets/textures/thumbnails/generic"
	thumbs_generic.clear()
	var files = saveload.parse_dir(thumbspath, ".svg")
	for turr in files:
		thumbs_generic[turr] = load(thumbspath + "/" + turr)

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
		var tback = button.get_node("texture_back");
		
		if opt.type == "turret buy":
			var tinfo = load_turrets.info[opt.name]
			button.get_node("name").text = tinfo.name
			button.get_node("panel_cash").visible = true
			button.get_node("cash").text = resources.dict_to_str(tinfo.cost)
			button.get_node("texture").texture = load_turrets.thumbnails[tinfo.thumbnail_name]
		if opt.type == "turret upg":
			var tinfo = load_turrets.info[opt.name]
			button.get_node("name").text = tinfo.name
			button.get_node("panel_cash").visible = true
			button.get_node("cash").text = resources.dict_to_str(tinfo.cost)
			button.get_node("texture").texture = load_turrets.thumbnails[tinfo.thumbnail_name]
			tback.texture = thumbs_generic["upgrade.svg"]
		if opt.type == "text":
			button.get_node("name").text = opt.name
			if opt.name == "back": tback.texture = thumbs_generic["back.svg"]
			if opt.name == "modules": tback.texture = thumbs_generic["modules.svg"]
			if opt.name == "targeting": tback.texture = thumbs_generic["targeting.svg"]
			if opt.name == "sell": tback.texture = thumbs_generic["sell.svg"]
			tback.modulate = Color.white
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
