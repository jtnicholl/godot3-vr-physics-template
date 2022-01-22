class_name Pickup extends RigidBody

export(bool) var throwable := true

onready var grab_points: Array = $GrabPoints.get_children()

onready var _original_parent := get_parent()
var _holder: Spatial = null
var _collision_shapes := []

func _ready():
	assert(!grab_points.empty(), name + " has no valid grab points")
	for current_child in get_children():
		if current_child is CollisionShape:
			_collision_shapes.append(current_child)


func _exit_tree():
	assert(_holder == null, name + " was removed from the tree while still being held")


func pick_up(by: Spatial) -> void:
	if is_instance_valid(_holder):
		return
	_reparent_self(by)
	_reparent_shapes(by)
	_holder = by
	mode = RigidBody.MODE_STATIC


func release(impulse := Vector3.ZERO) -> void:
	_holder = null
	_reparent_shapes(self)
	_reparent_self(_original_parent)
	mode = RigidBody.MODE_RIGID
	if throwable:
		apply_central_impulse(impulse)


func _reparent_self(to: Spatial) -> void:
	var original_transform := global_transform
	get_parent().remove_child(self)
	to.add_child(self)
	global_transform = original_transform


func _reparent_shapes(to: Spatial) -> void:
	for current_shape in _collision_shapes:
		var original_transform: Transform = current_shape.global_transform
		current_shape.get_parent().remove_child(current_shape)
		to.add_child(current_shape)
		current_shape.global_transform = original_transform
