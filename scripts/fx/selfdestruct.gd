extends Node

var timer = 0
var time_life = 3

func _physics_process(delta):
	timer += delta
	if timer >= time_life: queue_free()
