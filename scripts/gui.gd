extends Panel

var _player
var _label

func _ready():
	_player = self.get_parent().get_parent().find_node("player")
	_label = self.find_node("Label")

func _process(delta):
	_label.text = str(_player.sel_map[_player.sel])

