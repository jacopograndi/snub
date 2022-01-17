extends KinematicBody

var vel = Vector3()

var camera = Camera

var _mouse = Vector2()
var sensitivity_mouse = 10

var placer : Spatial

var _pivot
var _pivot_dist
var _orbit_timer

func _ready():	
	camera = $camera
	placer = $placer

func look_free (m):
	self.transform.basis = self.transform.basis.rotated(Vector3.UP, m.x)
	var rrrot = self.transform.basis.get_rotation_quat()
	self.transform.basis = self.transform.basis.rotated(rrrot*Vector3.RIGHT, m.y)
	
func look_orbit(m):	
	var diff : Vector3 = self.transform.origin - _pivot
	_pivot_dist = diff.length()
	var orbit : Basis = Transform.looking_at(diff, Vector3.UP).basis
	orbit = orbit.rotated(Vector3.UP, m.x)
	orbit = orbit.rotated(orbit.get_rotation_quat()*Vector3.RIGHT, -m.y)
	
	self.transform.origin = _pivot - orbit.z * _pivot_dist
	
	diff = self.transform.origin - _pivot
	self.transform.basis = self.transform.basis.slerp( \
		Transform.looking_at(-diff, Vector3.UP).basis, _orbit_timer)
	

func _move_input(delta):
	var m = _mouse
	m *= delta
	_mouse = Vector2()

	if Input.is_action_just_pressed("orbit"):
		if placer.colliding:
			_pivot = placer.collision_point
			var diff : Vector3 = self.transform.origin - _pivot
			_pivot_dist = diff.length()
			_orbit_timer = 0
		else: _pivot = null
		
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_pressed("orbit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if _pivot != null:
			_orbit_timer = min(1, _orbit_timer+delta * 2)
			look_orbit(m)
		else:
			look_free(m)
	elif Input.is_action_pressed("look"):
		look_free(m)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	var input_movement_vector = Vector3()
	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.z -= 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.z += 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1
	if Input.is_action_pressed("movement_up"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_down"):
		input_movement_vector.y -= 1
	input_movement_vector = input_movement_vector.normalized()
	
	var dir : Vector3 = self.transform.basis.get_rotation_quat() * input_movement_vector
	
	vel += dir * delta;
	vel *= 0.8
	
	var collision = self.move_and_collide(vel)
	if collision: vel = Vector3(0, 0, 0)

func _physics_process(delta):
	_move_input(delta)

func _input(event):
	if event is InputEventMouseMotion:
		_mouse += Vector2(
			deg2rad(event.relative.x) * -1, 
			deg2rad(event.relative.y) * -1) * sensitivity_mouse
