extends Spatial

var _enemies_holder
var _fx_holder
var load_scenes
var shooter

var damage = 0
var aoe = 0
var slowness_effect = 0
var slowness_time = 0

var timer = 0
var time_life = 3
var speed = 7
var hit_something = false
var bounce = false
var hitlist = []

var ignore_collisions = false

func _ready():
	var root = get_tree().root.get_node("world")
	_enemies_holder = root.get_node("enemies")
	_fx_holder = root.get_node("fx")
	var _err = $Area.connect("body_entered", self, "collided")
	var saveload = root.get_node("saveload")
	load_scenes = saveload.get_node("load_scenes")
	
func bounce_physics (delta):
	var forward_dir = -global_transform.basis.z.normalized()
	var space: PhysicsDirectSpaceState = get_world().direct_space_state
	var from = transform.origin 
	var to = transform.origin + forward_dir * speed * delta
	var mask = 0b0101
	var result = space.intersect_ray(from, to, [], mask)
	if result.size() > 0:
		hitlist.clear()
		var bounced = forward_dir.bounce(result.normal).normalized()
		var z = -bounced;
		var x = bounced.cross(result.normal).normalized();
		var y = x.cross(z).normalized();
		var basis = Basis(x, y, z);
		global_transform.basis = basis
		forward_dir = -global_transform.basis.z.normalized()
		var dist = transform.origin.distance_to(result.position)
		transform.origin = result.position
		var amt = speed * delta - dist
		global_translate(forward_dir * amt)
	else:
		global_translate(forward_dir * speed * delta)

func _physics_process(delta):
	timer += delta
	if timer >= time_life:
		if aoe > 0: explode()
		queue_free()
		return
	
	if bounce:
		bounce_physics(delta)
	else:
		var forward_dir = -global_transform.basis.z.normalized()
		global_translate(forward_dir * speed * delta)
		

func explode ():
	var space = get_world().direct_space_state
	
	var shape = SphereShape.new()
	shape.radius = aoe
	
	var params: = PhysicsShapeQueryParameters.new()
	params.set_shape(shape)
	params.collision_mask = 0b1000
	params.transform = transform
	
	var result = space.intersect_shape(params)
	for body in result:
		apply_damage(body.collider.get_parent().name)
		
	var fx_ex = load_scenes.fx_explosion.instance()
	fx_ex.transform = transform
	fx_ex.transform.basis = fx_ex.transform.basis.scaled(Vector3.ONE * aoe)
	fx_ex.time_life = 0.2
	_fx_holder.add_child(fx_ex)

func collided(body):
	var parent = body.get_parent()
	if parent == shooter: return
	if parent in hitlist: return
	
	if hit_something == false:
		var groups = parent.get_groups()
		## TODO design? aoe damages twice: on hit and aoe
		if "enemies" in groups: apply_damage(parent.name)
		if aoe > 0: explode()
			
	if !bounce:
		hit_something = true
		if aoe > 0: explode()
		queue_free()
	else:
		hitlist.append(parent)

func apply_damage (enemyname):
	_enemies_holder.damage(enemyname, damage, slowness_effect, slowness_time)
	
