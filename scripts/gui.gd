extends Control

var player : Node
var control : Node
var wave : Node

var bottom_bar : Control
var top_bar : Control
var wave_ongoing : Panel
var load_map : PanelContainer
var save_as : AcceptDialog
var delete_confirm : AcceptDialog
var edit_palette : AcceptDialog
var saveload : Node
var saveload_map : Node

func _fetch ():
	var root = get_tree().root.get_node("world")
	player = root.get_node("player")
	control = player.get_node("control")
	wave = root.get_node("wave")
	saveload = root.get_node("saveload")
	saveload_map = saveload.get_node("saveload_map")
	
	if bottom_bar == null: bottom_bar = get_node("bottom_bar")
	if top_bar == null: top_bar = get_node("top_bar")
	if wave_ongoing == null: wave_ongoing = $wave_ongoing_indicator
	if load_map == null: load_map = $gui_load_map
	if save_as == null: 
		save_as = $save_as
		save_as.register_text_enter(save_as.get_node("line_edit"))
	if delete_confirm == null: 
		delete_confirm = $delete_confirm
	if edit_palette == null: 
		edit_palette = $edit_palette

func _ready():
	_fetch()

func refresh ():
	_fetch()
	
	bottom_bar.refresh(control.ineditor)
	top_bar.refresh(control.ineditor)
	
	if wave.ongoing: wave_ongoing.visible = true
	else: wave_ongoing.visible = false

func save_as_mapname():
	var mapname = save_as.get_node("line_edit").text
	if !mapname.ends_with(".json"): mapname += ".json"
	control.gui_save_as_map_event(mapname)
	save_as.visible = false
	load_map.build()

func _on_save_as_confirmed(): 
	save_as_mapname()

func _on_delete_confirmed():
	control.gui_delete_map_event(load_map.selected_delete)
	load_map.build()

func _on_close_load_map():
	load_map.visible = false

func _on_edit_palette_confirmed():
	control.gui_picked_color(edit_palette.get_node("ColorPicker").color)
