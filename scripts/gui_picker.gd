extends Panel

var _hbox : HBoxContainer
var _gui_button : Resource = load("res://scenes/gui/gui_button.tscn")
var _gui_turret_button : Resource = load("res://scenes/gui/gui_turret.tscn")

var _options = []

var gui : Control

var hovering = ""

func _fetch ():
	if gui == null: gui = get_parent().gui
	if _hbox == null: _hbox = $Hbox

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
		var button = null
		if opt.type == "turret buy":
			button = _gui_turret_button.instance()
			_hbox.add_child(button)
			button.init(opt.name)
		if opt.type == "turret upg":
			button = _gui_turret_button.instance()
			_hbox.add_child(button)
			button.init(opt.name)
		if opt.type == "text":
			button = _gui_button.instance()
			_hbox.add_child(button)
			button.get_node("hbox").get_node("name_label").text = opt.name
		if opt.type == "color":
			button = _gui_button.instance()
			_hbox.add_child(button)
			button.get_node("hbox").get_node("name_label").text = ""
			button.get_node("color").color = opt.color
		
		if button != null:
			button.option = opt.name
		else: print("no option for " + str(opt))
		
	for child in _hbox.get_children():
		child.connect("mouse_entered", self, "_on_gui_turret_mouse_entered", [child.option])
		child.connect("mouse_exited", self, "_on_gui_turret_mouse_exited", [child.option])
		child.connect("pressed", self, "_on_gui_turret_pressed", [child.option])

func refresh ():
	_fetch()
	if gui.control.state == Globals.PlayerState.PICK:
		for child in _hbox.get_children(): child.picked = false
	if gui.control.selected == name:
		for child in _hbox.get_children():
			child.picked = child.name == gui.control.selected
	
func _on_gui_turret_mouse_entered(option : String):
	hovering = option;
	
func _on_gui_turret_mouse_exited(option : String):
	hovering = ""
	
func _on_gui_turret_pressed(option : String):
	gui.control.do(Globals.PlayerActions.PICK, { "selected": option })
