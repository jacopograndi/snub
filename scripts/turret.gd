extends Spatial

var _path
var _enemies
var _projectiles_holder

var _base
var _gun
var _shooting_point
var _normal

var aim_mode = "first"
var _target = null

var _range = 10

var projectile

var cooldown = 0.1
var cooldown_timer = 0

func _ready():
	_path = get_tree().root.get_child(0).find_node("path")
	_enemies = get_tree().root.get_child(0).find_node("enemies")
	_projectiles_holder = get_tree().root.get_child(0).find_node("projectiles")
	
	projectile = load("res://scenes/projectiles/bullet.tscn")
	
func refresh_normal ():
	_normal = transform.basis * Vector3.UP
	_shooting_point = transform.origin + 0.25 * _normal
	
func refresh_model():
	_base = get_node("model").find_node("pivot*").find_node("base*")
	_gun = _base.find_node("gun*")
	
func filter_in_range(set):
	var filtered = []
	for target in set:
		var node = _enemies.node_from_id(target)
		var dist = (node.transform.origin - _shooting_point).length_squared()
		if dist < _range*_range:
			filtered += [target]
	return filtered
	
func filter_visible(set):
	var space: PhysicsDirectSpaceState = get_world().direct_space_state as PhysicsDirectSpaceState
	var from = _shooting_point
	
	var filtered = []
	for target in set:
		var node = _enemies.node_from_id(target)
		var to = node.transform.origin
		var result = space.intersect_ray(from, to, _path.nodes, 1)
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
		var base_rot = Transform().looking_at(proj_normal, _normal).basis.get_rotation_quat()
			
		var perp = proj_normal.cross(_normal).normalized()
		var proj_forward = direction - perp.dot(direction) * perp
		var gun_rot = Transform().looking_at(proj_forward, perp).basis.get_rotation_quat()
			
		gun_rot = Quat(direction, PI/2) * gun_rot
		
		_base.global_transform.basis = Basis(base_rot)
		_gun.global_transform.basis = Basis(gun_rot)
		
		cooldown_timer += delta
		if cooldown_timer > cooldown:
			cooldown_timer -= cooldown
			shoot(direction)

func shoot (dir):
	shoot_projectile(dir)

func shoot_projectile (dir):
	var instance = projectile.instance()
	_projectiles_holder.add_child(instance)
	instance.transform = Transform().looking_at(dir, _normal)
	instance.transform.origin = _shooting_point + dir*0.3;
	instance.shooter = self
