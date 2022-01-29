extends Spatial

var _path : Node
var _enemies : Node
var _fx_holder : Node
var _projectiles_holder : Node
var _enemies_holder : Node
var load_turrets : Node

var pivot : Spatial
var base : Spatial
var gun : Spatial
var _shooting_point : Vector3
var _normal : Vector3

var aim_mode = "first"
var _target = null

var cooldown_timer = 0

var projectile : PackedScene
var ray : PackedScene

var info : Dictionary
var info_mod : Dictionary

var mods = []

func dict_get (d, keys : Array):
	var val = d
	if keys != [] and d != null: 
		var key = keys.pop_front()
		val = dict_get(d.get(key, null), keys)
	return val
	
func complete (prev, chain):
	for k in prev:
		if prev[k] is Dictionary: 
			complete(prev[k], chain + [k])
		else:
			for m in mods:
				var mod = load_turrets.modules[m]
				if not mod.has("add"): continue
				var children = dict_get(mod, ["add"] + chain)
				if children == null: continue
				for h in children:
					if children[h] is int or children[h] is float: 
						if not prev.has(h): 
							prev[h] = 0
							break
	
func traverse (prev, next, chain):
	for k in prev:
		if prev[k] is Dictionary: 
			if not next.has(k): next[k] = {}
			traverse(prev[k], next[k], chain + [k])
		else:
			var add = 0
			var mul = 0
			for m in mods:
				var mod = load_turrets.modules[m]
				var x = dict_get(mod, ["add"] + chain + [k])
				if x is int or x is float: add += x
				var y = dict_get(mod, ["mul"] + chain + [k])
				if y is int or y is float: mul += y
			if prev[k] is int or prev[k] is float: 
				next[k] = prev[k] + add
				next[k] = next[k] * (1+mul)
			else: next[k] = prev[k]

func make_info_mod ():
	info_mod.clear()
	complete(info, [])
	traverse(info, info_mod, []) 
	
	print(info, info_mod)

func _ready():
	var root = get_tree().root.get_node("world")
	_path = root.get_node("path")
	_enemies = root.get_node("enemies")
	_projectiles_holder = root.get_node("projectiles")
	_enemies_holder = root.find_node("enemies")
	_fx_holder = root.find_node("fx")
	
	load_turrets = root.get_node("saveload").get_node("load_turrets")
	if !load_turrets.loaded: yield(load_turrets, "done_loading")
	
	projectile = load("res://scenes/projectiles/bullet.tscn")
	ray = load("res://scenes/projectiles/ray.tscn")
	
func refresh_normal ():
	_normal = transform.basis * Vector3.UP
	_shooting_point = transform.origin + 0.25 * _normal
	
func refresh_model():
	pivot = get_node("model").find_node("pivot*", true, true)
	base = pivot.find_node("base*", true, true)
	if base != null:
		gun = base.find_node("gun*", true, true)
		
func refresh_info(tinfo):
	self.info = tinfo
	make_info_mod()
	
func filter_in_range(set):
	var filtered = []
	for target in set:
		var node = _enemies.node_from_id(target)
		var dist = (node.transform.origin - _shooting_point).length_squared()
		if dist < info_mod.range*info_mod.range:
			filtered += [target]
	return filtered
	
func filter_visible(set):
	var space: PhysicsDirectSpaceState = get_world().direct_space_state
	var from = _shooting_point
	var mask = 0b1101
	
	var filtered = []
	for target in set:
		var node = _enemies.node_from_id(target)
		var to = node.transform.origin
		var result = space.intersect_ray(from, to, _path.nodes, mask)
		if result.size() > 0:
			var hit = result.collider.get_parent()
			if hit == node:
				filtered += [ target ]
	return filtered

func get_target():
	var ids = []
	for id in _enemies.enemies: ids.append(id)
	var set = ids
	set = filter_in_range(set)
	set = filter_visible(set)
	
	if set.size() > 0:
		return set[0]
	else: return null

func _physics_process(delta):
	if !info_mod.has("projectile"): return 
	
	if !_enemies.enemies.has(_target):
		_target = null
	else:
		if _enemies.enemies[_target].hp <= 0:
			_target = null
		
	if _target == null: 
		_target = get_target()
	
	_target = get_target()
	
	var turn_speed = info_mod.get("turn_speed", 0)
		
	if _target != null:
		var enemy = _enemies.node_from_id(_target)
		var direction = (enemy.transform.origin - _shooting_point).normalized()
		
		var proj_normal = direction - _normal.dot(direction) * _normal
		var base_rot : Quat = Transform().looking_at(proj_normal, _normal).basis.get_rotation_quat()
			
		var perp = -proj_normal.cross(_normal).normalized()
		var proj_forward = direction - perp.dot(direction) * perp
		var gun_rot : Quat = Transform().looking_at(proj_forward, perp).basis.get_rotation_quat()
			
		gun_rot = Quat(direction, PI/2) * gun_rot
		gun_rot = gun_rot.normalized()
		gun_rot = base_rot.inverse() * gun_rot
		
		var base_basis = base.global_transform.basis.get_rotation_quat()
		var base_angle = base_basis.angle_to(base_rot)
		if base_angle > 0.01:
			var base_amt = (turn_speed * delta) / base_angle
			base_amt = min(1, base_amt)
			base.global_transform.basis = Basis(base_basis.slerp(Basis(base_rot), base_amt))
			
		var gun_basis = gun.transform.basis.get_rotation_quat()
		var gun_angle = gun_basis.angle_to(gun_rot)
		if gun_angle > 0.01:
			var gun_amt = (turn_speed * delta) / gun_angle
			gun_amt = min(1, gun_amt)
			gun.transform.basis = Basis(gun_basis.slerp(Basis(gun_rot), gun_amt))
		
		cooldown_timer += delta
		if cooldown_timer > info_mod.cooldown:
			cooldown_timer -= info_mod.cooldown
			shoot()
			
func spread (amt : int) -> Array:
	var dirs = []
	var width : int = ceil(sqrt(amt))
	for i in amt:
		var dir = gun.global_transform.basis
		var x = floor(i%width)-width/2+(width+1)%2*0.5
		var y = floor(i/width)-floor(sqrt(amt)-1)/2
		var spread = info_mod.projectile.spread
		dir = dir.rotated(_normal, deg2rad(x*spread))
		dir = dir.rotated(_normal.cross(dir.z).normalized(), deg2rad(y*spread))
		dirs.append(dir)
	return dirs

func shoot ():
	if info_mod.projectile.get("amount", 1) > 1:
		for dir in spread(info_mod.projectile.amount):
			shoot_switch(dir)
	else:
		shoot_switch(gun.global_transform.basis)
			
func shoot_switch (dir : Basis):
	match info_mod.projectile.type:
		"bullet": shoot_bullet(dir)
		"ray": shoot_ray(dir)
		"bounce": shoot_bullet(dir, true)

func shoot_bullet (dir : Basis, bounce = false):
	var instance = projectile.instance()
	_projectiles_holder.add_child(instance)
	instance.transform.basis = dir
	instance.transform.origin = _shooting_point - dir.z*0.3;
	instance.shooter = self
	instance.damage = info_mod.projectile.get("damage", 0)
	instance.speed = info_mod.projectile.get("speed", 0)
	instance.bounce = bounce
	instance.aoe = info_mod.projectile.get("area_of_effect", 0)
	instance.slowness_effect = info_mod.projectile.get("slowness_effect", 0)
	instance.slowness_time = info_mod.projectile.get("slowness_time", 0)
	instance.time_life = info_mod.projectile.get("lifetime", 3)

func shoot_ray (dir : Basis):
	var space: PhysicsDirectSpaceState = get_world().direct_space_state
	var from = _shooting_point
	var to = _shooting_point - dir.z*info_mod.range
	var mask = 0b1101
	
	var result = space.intersect_ray(from, to, _path.nodes, mask)
	if result.size() > 0:
		var parent = result.collider.get_parent()
		var groups = parent.get_groups()
		if "enemies" in groups:
			var dam = info_mod.projectile.get("damage", 0)
			var eff = info_mod.projectile.get("slowness_effect", 0)
			var tim = info_mod.projectile.get("slowness_time", 0)
			_enemies_holder.damage(parent.name, dam, eff, tim)
			
			var distance = result.position.distance_to(from)
			
			var instance = ray.instance()
			_fx_holder.add_child(instance)
			instance.transform.origin = _shooting_point - dir.z*0.3;
			instance.transform.basis = dir
			instance.transform.basis.z *= distance
			instance.time_life = 0.05
			
