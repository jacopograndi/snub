extends Control

var editor_bar : Control
var picker : Control

var gui : Control

func _fetch ():
	if gui == null: gui = get_parent()
	if editor_bar == null: editor_bar = $editor_bar
	if picker == null: picker = $picker

func refresh (in_editor : bool):
	_fetch()
	
	if in_editor:
		editor_bar.visible = true
	else:
		editor_bar.visible = false
		
	picker.refresh()

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

func _on_palette_button_up():
	gui.control.do(Globals.PlayerActions.CHANGE_TYPE, 
		{ "statetype": Globals.StateType.VOXEL_PALETTE })
