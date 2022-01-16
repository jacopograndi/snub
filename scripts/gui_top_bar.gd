extends Control

var _editor_button : Button
var _hbox : HBoxContainer

var _resources : Node
var _gui : Control

func refresh (in_editor : bool):
	var root = get_tree().root.get_node("world")
	_resources = root.get_node("player").get_node("resources")
	
	if _gui == null: _gui = get_parent()
	if _hbox == null: _hbox = $panel/resources/HBoxContainer
	if _editor_button == null: _editor_button = $panel/editor_button

	if in_editor: _editor_button.text = "Editor"
	else: _editor_button.text = "Playmode"

func _process (_delta):
	for r in _resources.get_names():
		_hbox.get_node(r).text = str(_resources[r]) + r
		
func _on_editor_button_down():
	_gui.control.gui_editor_toggle_event()

func _on_wave_button_pressed():
	_gui.control.gui_start_wave_event()
