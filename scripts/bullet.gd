extends Spatial

var _enemies_holder
var shooter

var damage = 1

var timer = 0
var time_life = 3
var speed = 7
var hit_something = false
var bounce = false
var hitlist = []

func _ready():
	_enemies_holder = get_tree().root.get_node("world").find_node("enemies")
	var _err = $Area.connect("body_entered", self, "collided")

func _physics_process(delta):
	var forward_dir = -global_transform.basis.z.normalized()
	if bounce:
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
	else:
		global_translate(forward_dir * speed * delta)
		
	
	timer += delta
	if timer >= time_life:
		queue_free()

func collided(body):
	var parent = body.get_parent()
	if parent == shooter: return
	if parent in hitlist: return
	
	if hit_something == false:
		var groups = parent.get_groups()
		if "enemies" in groups:
			_enemies_holder.damage(parent.name, damage)
			

	if !bounce:
		hit_something = true
		queue_free()
	else:
		hitlist.append(parent)

