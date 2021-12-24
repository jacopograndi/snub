extends Spatial

var timer = 0
var timer_life = 1

var anim_size = 1

var _mesh : MeshInstance

var base

func refresh_shader(mat, color : Color):
	_mesh = get_child(0).get_child(0)
	_mesh.set_surface_material(0, mat)
	_mesh.get_active_material(0).set_shader_param("albedo", color)
	
func refresh_basis():
	base = transform.basis

func _physics_process(delta):
	timer += delta
	if timer > timer_life:
		queue_free()
		
	var amt = timer / timer_life
	
	_mesh.get_active_material(0).set_shader_param("offset", amt)

	anim_size = 1+ amt * 0.1
	transform.basis = base.scaled(Vector3(anim_size, anim_size, anim_size))
