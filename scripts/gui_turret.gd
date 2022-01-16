extends TextureButton

var option : String

var info : Dictionary

var _color_rect : ColorRect
var _name_label : Label
var _cash_label : Label

var _viewport : Viewport
var _spinner : Node
var _mesh : Node

var _resources : Node

var picked : bool
var enabled : bool = false

var _rotate_timer : float

func init (turret_name : String):
	var root = get_tree().root.get_node("world")
	var saveload = root.get_node("saveload")
	var load_turrets = saveload.get_node("load_turrets")
	if !load_turrets.loaded: yield(load_turrets, "done_loading")
	info = load_turrets.info[turret_name]
	
	_color_rect = $ColorRect
	_name_label = $hbox/name_label
	_cash_label = $cash_label
	_viewport = $viewport
	_spinner = $viewport/spinner
	
	_resources = root.get_node("player").get_node("resources")
	
	_name_label.text = turret_name
	_cash_label.text = _resources.dict_to_str(info.cost)
	
	var model = load_turrets.models[info.model_name]
	_mesh = model.instance()
	_spinner.add_child(_mesh)
	
	texture_normal = _viewport.get_texture()
	
func _process(delta):
	if !has_node("viewport"): return
	if _spinner == null: _spinner = $viewport/spinner
	if _spinner != null:
		if _resources == null:
			var root = get_tree().root.get_node("world")
			_resources = root.get_node("player").get_node("resources")
		
		var afforded = _resources.greater_than(info.cost)
		if afforded: _color_rect.color = Color(0,0,0,0)
		else: _color_rect.color = Color(0,0,0,0.5)
			
		if afforded and (is_hovered() or picked):
			_spinner.transform.basis = _spinner.transform.rotated(Vector3.UP, delta).basis
			_rotate_timer = 0
		else:
			_rotate_timer = min(1, _rotate_timer + delta * 5)
			var idle_rot = Transform.rotated(Vector3.UP, PI-PI/4).basis
			_spinner.transform.basis = _spinner.transform.basis.slerp(idle_rot, _rotate_timer)
