class_name Grabbable extends RigidBody


onready var grab_points := $GrabPoints.get_children()


func _ready() -> void:
	assert(not grab_points.empty(), name + " has no valid grab points")


func grab(_by: PhysicsBody) -> void:
	pass


func release(_impulse := Vector3.ZERO) -> void:
	pass
