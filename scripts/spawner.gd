extends Timer

var enemy_holder : Node
var queue : Array

func fetch ():
	var root = get_tree().root.get_node("world")
	enemy_holder = root.get_node("enemies")
	
func next ():
	if queue.size() == 0: return null
	var n = queue[0]
	queue.remove(0)
	return n

func _on_timer_batch_timeout():
	# fetch called by wave
	var n = next()
	if n == null:
		queue_free()
		return
		
	enemy_holder.spawn(n.enemy)
	start(n.cooldown)
