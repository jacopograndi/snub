extends PanelContainer

var vbox_items
var _gui_item : Resource = load("res://scenes/gui/gui_map_item.tscn")
var saveload_map : Node

var control : Node
var gui : Control

var selected_delete = ""

func _fetch ():
	if gui == null: gui = get_parent()
	if saveload_map != null: return;
	
	vbox_items = $"vbox/vbox_items"
	
	var root = get_tree().root.get_node("world")
	control = root.get_node("player").get_node("control")
	saveload_map = root.get_node("saveload").get_node("saveload_map")
	
func build ():
	_fetch()
	
	var txt = "load map from " + saveload_map.mappath
	get_node("vbox").get_node("title").text = txt
	
	var mapnames = saveload_map.get_mapnames()
	for child in vbox_items.get_children(): child.queue_free()
	
	for mapname in mapnames:
		var item = _gui_item.instance()
		item.get_node("name").text = mapname
		vbox_items.add_child(item)
		
		var button_load = item.get_node("hbox").get_node("load")
		button_load.connect("pressed", self, "_load_pressed", [mapname])
		
		var button_delete = item.get_node("hbox").get_node("delete")
		button_delete.connect("pressed", self, "_delete_pressed", [mapname])
	
func refresh ():
	_fetch()
	
func _delete_pressed (mapname : String):
	gui.delete_confirm.popup()
	gui.delete_confirm.dialog_text = "You are about to delete this map:\n"+mapname
	selected_delete = mapname
	
func _load_pressed (mapname : String):
	control.gui_change_map_event(mapname)
