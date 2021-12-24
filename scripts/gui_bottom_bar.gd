extends Control

var _in_editor : bool
var voxel_picker : Control
var map_tool_picker : Control
var turret_picker : Control

var _load_turrets : Node

var gui : Control

func _fetch ():
	if gui == null: gui = get_parent()
	if voxel_picker == null: voxel_picker = $voxels
	if map_tool_picker == null: map_tool_picker = $map_tools
	if turret_picker == null: turret_picker = $turrets
	
	var root = get_tree().root.get_child(0)
	if _load_turrets == null: 
		_load_turrets = root.get_node("saveload").get_node("load_turrets")

func build ():
	_fetch()
	turret_picker.build(_load_turrets.get_base_turrets())
	voxel_picker.build()
	map_tool_picker.build()

func refresh (in_editor : bool):
	_fetch()
	_in_editor = in_editor 
	
	if _in_editor:
		voxel_picker.visible = true
		map_tool_picker.visible = true
	else:
		voxel_picker.visible = false
		map_tool_picker.visible = false
		
	turret_picker.refresh(gui.player.sel)
	voxel_picker.refresh(gui.player.sel)
	map_tool_picker.refresh(gui.player.sel)
