extends Node

var _timer : Resource = load("res://scenes/wave/timer_batch.tscn")

var wave_num : int = 0
var waves = []

var ongoing = false

var load_shapes : Node
var gui : Node

var rng = RandomNumberGenerator.new()

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
				"enemy": order.enemy,
				"hp": order.hp
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

func sort_aff_comp(a, b): return a.cost < b.cost
		
func pick_enemy (hp_budget : int, density : float, height: float):
	var amt = 1
	var aff = get_affordable_enemies(hp_budget)
	aff.sort_custom(self, "sort_aff_comp")
	
	#var rn = rng.randf()
	#var pick : float = pow(rn, 2*height*(1-rn) + rn)
	var enemy = aff[round(height * (aff.size()-1))]
	
	var cooldown : float = rng.randf() * pow(4, density - 0.5)
	
	var hp_adjusted = max(1, enemy.lives * height)
	var cost = enemy.cost - enemy.lives + hp_adjusted
	
	print(cost)
	
	var order = {
		"amount" : amt,
		"enemy": enemy.name,
		"hp": hp_adjusted,
		"cooldown": cooldown
	}
	return { "enemy": order, "cost": cost }

func gen_wave (wave_num : int, density : float, height: float):
	var hp_budget = get_hp_budget(wave_num)
	
	var enemies = []
	for i in range(0, 1000):
		if hp_budget < 10: break
		var enemy_cost = pick_enemy(hp_budget, density, height)
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
	rng.randomize()
	ongoing = true
	var w = null
	if wave_num <= waves.size()-1: w = waves[wave_num]
	else: w = gen_wave(wave_num, 0.5, 0.2)
	start_wave(w)
	
func end():
	ongoing = false
	wave_num += 1
