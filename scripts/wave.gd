extends Node

var _timer : Resource = load("res://scenes/wave/timer_batch.tscn")

var wave_num : int = 0
var waves = []

var ongoing = false

var load_shapes : Node
var gui : Node

func fetch ():
	var root = get_tree().root.get_node("world")
	var saveload = root.get_node("saveload")
	load_shapes = saveload.get_node("load_shapes")
	gui = root.get_node("gui")

func make_queue (spawn):
	var queue = []
	for order in spawn.enemies:
		for n in order.amount:
			var e = {
				"cooldown": order.cooldown,
				"enemy": order.enemy
			}
			queue += [e]
	if spawn.random: queue.shuffle()
	return queue

func add_spawner (spawn):
	var timer = _timer.instance()
	timer.queue = make_queue(spawn)
	add_child(timer)
	timer.fetch()
	timer.start(spawn.time)
	
func start_wave (wave):
	for spawn in wave:
		add_spawner(spawn)
		

func get_hp_budget (x : int):
	var hp = pow((x + 10), 2.7) * 1.8 - 850
	return hp
	
func get_affordable_enemies (hp_budget : int):
	var aff = []
	for enemy in load_shapes.info:
		if load_shapes.info[enemy].cost <= hp_budget:
			aff += [load_shapes.info[enemy]]
	return aff
		
func pick_enemy (hp_budget : int):
	var amt = 1
	var aff = get_affordable_enemies(hp_budget)
	var enemy = aff[randi() % aff.size()]
	var order = {
		"amount" : amt,
		"enemy": enemy.name,
		"cooldown": 0.5
	}
	return { "enemy": order, "cost": enemy.cost }

func gen_wave (wave_num : int):
	var hp_budget = get_hp_budget(wave_num)
	
	var enemies = []
	for i in range(0, 1000):
		if hp_budget < 10: break
		var enemy_cost = pick_enemy(hp_budget)
		enemies += [ enemy_cost.enemy ]
		hp_budget -= enemy_cost.cost
	
	var w = [
		{
			"time": 0, "random": true,
			"enemies": enemies
		}
	]
	return w

func start():
	fetch()
	ongoing = true
	var w = null
	if wave_num <= waves.size()-1: w = waves[wave_num]
	else: w = gen_wave(wave_num)
	start_wave(w)
	
func end():
	ongoing = false
	wave_num += 1
	gui.refresh()
