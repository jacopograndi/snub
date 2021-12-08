extends Panel

var _player
var _path
var _enemies

func _ready():
	_path = get_tree().root.get_child(0).find_node("path")
	_player = get_tree().root.get_child(0).find_node("player")
	_enemies = get_tree().root.get_child(0).find_node("enemies")

func _process(delta):
	pass


func _on_Button_button_down():
	_enemies.spawn()


func _on_Button2_button_down():
	var res = _path.load_nodes()
	_path.hide()
