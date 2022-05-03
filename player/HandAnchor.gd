class_name HandAnchor extends KinematicBody

export (NodePath) var controller
onready var _controller: VRController = get_node(controller)

var offset_position: Vector3

func _ready():
	assert(is_instance_valid(_controller), "Controller path was not set correctly for " + name)


func _physics_process(delta: float):
	var distance := _controller.to_global(offset_position) - self.global_transform.origin
	if distance.length_squared() < 1:
		move_and_slide(distance / delta)
	else:
		_copy_position()


func _copy_position() -> void:
	self.global_transform.origin = _controller.global_transform.origin
