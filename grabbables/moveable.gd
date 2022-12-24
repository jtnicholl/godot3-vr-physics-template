class_name Moveable extends Grabbable


onready var _joint := $Joint as Joint


func _exit_tree() -> void:
	release()


func grab(by: PhysicsBody) -> void:
	_joint["nodes/node_a"] = @".."
	_joint["nodes/node_b"] = _joint.get_path_to(by)
	_joint.global_transform.origin = by.global_transform.origin
	sleeping = false


func release(_impulse := Vector3.ZERO) -> void:
	_joint["nodes/node_a"] = @""
	_joint["nodes/node_b"] = @""
