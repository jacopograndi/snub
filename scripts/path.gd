extends Node

const dirs = [ 
	Vector3.UP, Vector3.DOWN, 
	Vector3.FORWARD, Vector3.BACK, 
	Vector3.LEFT, Vector3.RIGHT 
]

var nodes = []


func _ready():
	pass # Replace with function body.
	
func next_node (node, dir):
	var pos : Vector3 = node.transform.origin
	var rot : Quat = node.transform.basis.get_rotation_quat()
	var forward : Vector3 = rot * dir
	var probe : Vector3 = pos + forward * 0.5
	
	for child in get_children():
		var diff : Vector3 = child.transform.origin - probe
		var dist : float = diff.length_squared()
		if dist < 0.1:
			return child
		
	return null
	
func load_nodes ():
	var start = null
	for child in get_children():
		if "start" in child.name:
			start = child
	if start == null:
		return "failed to find start"
		
	var next = null
	for dir in dirs:
		var cand = next_node(start, dir)
		if cand != null:
			if next == null:
				next = cand
			else:
				return "failed: more than one path from start"
	if next == null:
		return "failed to find path next to start"
		
	nodes = [start, next]
	var iter = next
	while true:
		iter = next_node(iter, Vector3.UP)
		nodes.append(iter)
		if iter == null: 
			return "failed to follow path"
		if "end" in iter.name:
			break
			
	return "ok"

func hide ():
	for child in get_children():
		var mesh = child.find_node("MeshInstance")
		mesh.visible = false
		
func show ():
	for child in get_children():
		var mesh = child.find_node("MeshInstance")
		mesh.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
