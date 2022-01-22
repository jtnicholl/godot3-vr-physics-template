class_name Teleporter extends RayCast

signal teleported(global_position)

const _OK_TELEPORT_COLOR = Color(0xADFFC8FF)
const _NO_TELEPORT_COLOR = Color(0xFF4000FF)

export (float, 1, 10, 1) var max_distance = 5

onready var _collision_check: Area = $CollisionCheck
onready var _target_material: SpatialMaterial = $CollisionCheck/Target["material/0"]

func _ready():
	set_physics_process(false)


func _physics_process(_delta: float):
	if is_colliding():
		_collision_check.global_transform.origin = get_collision_point()
		_collision_check.global_transform.basis = Basis.IDENTITY
		_collision_check.show()
		_target_material.albedo_color = _OK_TELEPORT_COLOR if _can_teleport() else _NO_TELEPORT_COLOR
	else:
		_collision_check.hide()


func press() -> void:
	enabled = true
	_collision_check.show()
	set_physics_process(true)


func release() -> void:
	if enabled && _can_teleport():
		emit_signal("teleported", get_collision_point())
	set_physics_process(false)
	enabled = false
	_collision_check.hide()


func _can_teleport() -> bool:
	return _collision_check.get_overlapping_bodies().empty() && \
			global_transform.origin.distance_to(get_collision_point()) <= max_distance
