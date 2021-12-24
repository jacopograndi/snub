extends Panel

var _hbox : HBoxContainer
var _gui_button : Resource = load("res://scenes/gui/gui_turret.tscn")

var _options = []

var gui : Control

func _fetch ():
	if gui == null: gui = get_parent().gui
	if _hbox == null: _hbox = $ScrollContainer/Hbox

func build (options : Array = []):
	_fetch()
	
	if options.size() > 0:
		for n in _hbox.get_children(): n.queue_free()
	
		_options = options
		for t in _options:
			var gt : TextureButton = _gui_button.instance()
			gt.name = t.name
			_hbox.add_child(gt)
			gt.init(t)
		
	for child in _hbox.get_children():
		if child.get_signal_connection_list("pressed").size() == 0:
			child.connect("mouse_entered", self, "_on_gui_turret_mouse_entered", [child.name])
			child.connect("mouse_exited", self, "_on_gui_turret_mouse_entered", [child.name])
			child.connect("pressed", self, "_on_gui_turret_pressed", [child.name])

func refresh (sel = ""):
	_fetch()
	if sel.type == "":
		for child in _hbox.get_children(): child.picked = false
	if sel.type == name:
		for child in _hbox.get_children():
			child.picked = child.name == sel.name
	
func _on_gui_turret_mouse_entered(name : String):
	print(name + " entered from " + self.name)
	
func _on_gui_turret_mouse_exited(name : String):
	print(name + " exited from " + self.name)
	
func _on_gui_turret_pressed(name : String):
	print(name + " pressed from " + self.name)
	gui.player.selected_event(name, self.name)
