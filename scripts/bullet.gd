extends Spatial

var _enemies_holder
var shooter

var timer = 0
var time_life = 3
var speed = 7
var hit_something = false

func _ready():
	_enemies_holder = get_tree().root.get_child(0).find_node("enemies")
	$Area.connect("body_entered", self, "collided")

func _physics_process(delta):
	var forward_dir = -global_transform.basis.z.normalized()
	global_translate(forward_dir * speed * delta)

	timer += delta
	if timer >= time_life:
		queue_free()

func collided(body):
	var parent = body.get_parent()
	if parent == shooter: return
	
	if hit_something == false:
		var groups = parent.get_groups()
		if "enemies" in groups:
			_enemies_holder.damage(parent.name)

	hit_something = true
	queue_free()
