class_name Utils
extends Object

static func quat_look (target, up):
	var dot = target.dot(up)
	var angle = acos(dot)
	var axis = up.cross(target).normalized()
	if angle == 0: axis = up
	if angle == PI: axis = Vector3.RIGHT
	return Quat(axis, angle)
