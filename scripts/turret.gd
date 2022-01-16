extends Spatial

var _path : Node
var _enemies : Node
var _projectiles_holder : Node
var _enemies_holder : Node

var pivot : Spatial
var base : Spatial
var gun : Spatial
var _shooting_point : Vector3
var _normal : Vector3

var aim_mode = "first"
var _target = null

var projectile : PackedScene

var info : Dictionary

var cooldown_timer = 0

func _ready():
	var root = get_tree().root.get_node("world")
	_path = root.get_node("path")
	_enemies = root.get_node("enemies")
	_projectiles_holder = root.get_node("projectiles")
	_enemies_holder = root.find_node("enemies")
	
	projectile = load("res://scenes/projectiles/bullet.tscn")
	
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
	
func filter_in_range(set):
	var filtered = []
	for target in set:
		var node = _enemies.node_from_id(target)
		var dist = (node.transform.origin - _shooting_point).length_squared()
		if dist < info.range*info.range:
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
	if !info.has("damage"): return 
	
	if !_enemies.enemies.has(_target):
		_target = null
	else:
		if _enemies.enemies[_target].hp <= 0:
			_target = null
		
	if _target == null: 
		_target = get_target()
	
	_target = get_target()
		
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
			var base_amt = (info.turn_speed * delta) / base_angle
			base_amt = min(1, base_amt)
			base.global_transform.basis = Basis(base_basis.slerp(Basis(base_rot), base_amt))
			
		var gun_basis = gun.transform.basis.get_rotation_quat()
		var gun_angle = gun_basis.angle_to(gun_rot)
		if gun_angle > 0.01:
			var gun_amt = (info.turn_speed * delta) / gun_angle
			gun_amt = min(1, gun_amt)
			gun.transform.basis = Basis(gun_basis.slerp(Basis(gun_rot), gun_amt))
		
		cooldown_timer += delta
		if cooldown_timer > info.cooldown:
			cooldown_timer -= info.cooldown
			shoot()
			
func spread (amt : int) -> Array:
	var dirs = []
	var width : int = ceil(sqrt(amt))
	for i in amt:
		var dir = gun.global_transform.basis
		var x = floor(i%width)-width/2+(width+1)%2*0.5
		var y = floor(i/width)-floor(sqrt(amt)-1)/2
		var spread = info.projectile.spread
		dir = dir.rotated(_normal, deg2rad(x*spread))
		dir = dir.rotated(_normal.cross(dir.z).normalized(), deg2rad(y*spread))
		dirs.append(dir)
	return dirs

func shoot ():
	if info.projectile.amount > 1:
		for dir in spread(info.projectile.amount):
			shoot_switch(dir)
	else:
		shoot_switch(gun.global_transform.basis)
			
func shoot_switch (dir : Basis):
	match info.projectile.type:
		"bullet": shoot_bullet(dir)
		"ray": shoot_ray(dir)
		"bounce": shoot_bullet(dir, true)

func shoot_bullet (dir : Basis, bounce = false):
	var instance = projectile.instance()
	_projectiles_holder.add_child(instance)
	instance.transform.basis = dir
	instance.transform.origin = _shooting_point - dir.z*0.3;
	instance.shooter = self
	instance.damage = info.damage
	instance.speed = info.projectile.speed
	instance.bounce = bounce

func shoot_ray (dir : Basis):
	var space: PhysicsDirectSpaceState = get_world().direct_space_state
	var from = _shooting_point
	var to = _shooting_point - dir.z*info.range;
	var mask = 0b1101
	
	var result = space.intersect_ray(from, to, _path.nodes, mask)
	if result.size() > 0:
		var parent = result.collider.get_parent()
		var groups = parent.get_groups()
		if "enemies" in groups:
			_enemies_holder.damage(parent.name, info.damage)
