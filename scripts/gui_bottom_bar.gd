extends Control

var editor_bar : Control
var picker : Control

var gui : Control

var load_map : Control
var map_name : Label

func _fetch ():
	if gui == null: gui = get_parent()
	if editor_bar == null: editor_bar = $editor_bar
	if picker == null: picker = $picker
	if map_name == null: map_name = $editor_bar/hbox_map/mapname

func refresh (in_editor : bool):
	_fetch()
	
	if in_editor:
		editor_bar.visible = true
	else:
		editor_bar.visible = false
		
	picker.refresh()
	
	map_name.text = gui.saveload_map.mapname

func _on_turrets_button_up():
	gui.control.do(Globals.PlayerActions.CHANGE_TYPE, 
		{ "statetype": Globals.StateType.TURRET })

func _on_path_button_up():
	gui.control.do(Globals.PlayerActions.CHANGE_TYPE, 
		{ "statetype": Globals.StateType.PATH })

func _on_attach_button_up():
	gui.control.do(Globals.PlayerActions.CHANGE_TYPE, 
		{ "statetype": Globals.StateType.ATTACH })

func _on_voxel_button_up():
	gui.control.do(Globals.PlayerActions.CHANGE_TYPE, 
		{ "statetype": Globals.StateType.VOXEL })

func _on_save_button_up():
	gui.control.gui_save_map_event()

func _on_load_button_up():
	gui.load_map.build()
	gui.load_map.visible = true

func _on_save_as_button_up():
	gui.save_as.popup()
	gui.save_as.get_node("line_edit").grab_focus()
