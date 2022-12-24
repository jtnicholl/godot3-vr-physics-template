class_name VRPlayer extends Spatial


signal bounds_escaped()

export(bool) var can_move := true
export(float) var walk_speed := 1.0
export(float) var impulse_multiplier := 0.2
export(float) var fall_speed := 1.0

var teleporting_enabled: bool
var continuous_locomotion_enabled: bool
var locomotion_direction_source: int
var locomotion_update_mode: int

var _left_grabbable: Grabbable = null
var _right_grabbable: Grabbable = null
var _walking_input := Vector2.ZERO
var _locomotion_direction: float

onready var _body := $KinematicBody as KinematicBody
onready var _collision_shape := $KinematicBody/CollisionShape as CollisionShape
onready var _left_controller := $KinematicBody/ARVROrigin/LeftController as VRController
onready var _right_controller := $KinematicBody/ARVROrigin/RightController as VRController
onready var _left_hand := $LeftHand as VRHand
onready var _right_hand := $RightHand as VRHand
onready var _left_teleporter := $KinematicBody/ARVROrigin/LeftController/Teleporter as Teleporter
onready var _right_teleporter := $KinematicBody/ARVROrigin/RightController/Teleporter as Teleporter
onready var _camera := $KinematicBody/ARVROrigin/Camera as ARVRCamera
onready var _shape := _collision_shape.shape as CapsuleShape
onready var _out_of_bounds_player := $OutOfBoundsPlayer as AnimationPlayer


func _physics_process(_delta: float) -> void:
	_update_collision()
	if can_move and continuous_locomotion_enabled and not _walking_input.is_equal_approx(Vector2.ZERO):
		if locomotion_update_mode == Settings.LocomotionUpdateMode.CONTINUOUS:
			_update_locomotion_direction()
		var movement := _walking_input.rotated(-_locomotion_direction)
		_body.move_and_slide(Vector3(movement.x, -fall_speed, movement.y) * walk_speed, Vector3.UP)
	elif not _body.is_on_floor():
		_body.move_and_slide(Vector3.DOWN * fall_speed, Vector3.UP)


func position_feet(global_position: Vector3) -> void:
	var camera_offset := _camera.global_transform.origin - global_transform.origin
	_body.translation.y = 0
	camera_offset.y = 0
	global_transform.origin = global_position - camera_offset


func position_head(global_position: Vector3) -> void:
	var camera_offset := _camera.global_transform.origin - global_transform.origin
	global_transform.origin = global_position - camera_offset


func rotate_head(radians: float) -> void:
	var camera_offset := _camera.global_transform.origin - self.global_transform.origin
	var camera_offset_2d := Vector2(camera_offset.x, camera_offset.z)
	var camera_offset_difference := camera_offset_2d - camera_offset_2d.rotated(radians)
	rotate_y(-radians)
	global_translate(Vector3(camera_offset_difference.x, 0, camera_offset_difference.y))


func set_hand_offset(position: Vector3, rotation: Vector3) -> void:
	($RightHandAnchor as HandAnchor).offset_position = position
	position.x = -position.x
	($LeftHandAnchor as HandAnchor).offset_position = position
	_right_hand.offset_rotation = Basis(rotation)
	rotation.y = -rotation.y
	rotation.z = -rotation.z
	_left_hand.offset_rotation = Basis(rotation)


func _update_collision() -> void:
	_collision_shape.translation.x = _camera.translation.x
	_collision_shape.translation.z = _camera.translation.z
	_collision_shape.translation.y = (_camera.translation.y + _shape.radius) / 2
	_shape.height = _camera.translation.y - _shape.radius


func _try_grab(tracker_hand: int) -> void:
	var controller := _left_controller if tracker_hand == \
			ARVRPositionalTracker.TRACKER_LEFT_HAND else _right_controller
	var hand := _left_hand if tracker_hand == \
			ARVRPositionalTracker.TRACKER_LEFT_HAND else _right_hand
	var result := controller.try_grab(0.2)
	if result.grabbable != null:
		hand.global_transform = result.grab_point.global_transform
		hand.translate_object_local(controller.grab_offset)
		result.grabbable.grab(hand)
		if tracker_hand == ARVRPositionalTracker.TRACKER_LEFT_HAND:
			_left_grabbable = result.grabbable
		else:
			_right_grabbable = result.grabbable


func _update_locomotion_direction() -> void:
	match locomotion_direction_source:
		Settings.LocomotionDirectionSource.HEAD:
			_locomotion_direction = _camera.global_transform.basis.get_euler().y
		Settings.LocomotionDirectionSource.LEFT_CONTROLLER:
			_locomotion_direction = _left_controller.global_transform.basis.get_euler().y
		Settings.LocomotionDirectionSource.RIGHT_CONTROLLER:
			_locomotion_direction = _right_controller.global_transform.basis.get_euler().y


func _on_bounds_check_body_entered(_body: Node) -> void:
	_out_of_bounds_player.play("out_of_bounds")


func _on_bounds_check_body_exited(_body: Node) -> void:
	_out_of_bounds_player.play("RESET")


func _on_teleport_left_action_pressed() -> void:
	if can_move and teleporting_enabled:
		_right_teleporter.cancel()
		_left_teleporter.press()


func _on_teleport_left_action_released() -> void:
	_left_teleporter.release()


func _on_teleport_right_action_pressed() -> void:
	if can_move:
		_left_teleporter.cancel()
		_right_teleporter.press()


func _on_teleport_right_action_released() -> void:
	_right_teleporter.release()


func _on_teleporter_teleported(global_position: Vector3) -> void:
	if can_move:
		position_feet(global_position)


func _on_turn_left_action_pressed() -> void:
	rotate_head(-PI / 4.0)


func _on_turn_right_action_pressed() -> void:
	rotate_head(PI / 4.0)


func _on_grab_left_action_pressed() -> void:
	call_deferred("_try_grab", ARVRPositionalTracker.TRACKER_LEFT_HAND)


func _on_grab_left_action_released() -> void:
	if is_instance_valid(_left_grabbable):
		_left_grabbable.release(_left_hand.velocity * impulse_multiplier)
	_left_grabbable = null


func _on_grab_right_action_pressed() -> void:
	call_deferred("_try_grab", ARVRPositionalTracker.TRACKER_RIGHT_HAND)


func _on_grab_right_action_released() -> void:
	if is_instance_valid(_right_grabbable):
		_right_grabbable.release(_right_hand.velocity * impulse_multiplier)
	_right_grabbable = null


func _on_walk_forward_action_pressed() -> void:
	if can_move:
		_walking_input.y = -1.0
		_update_locomotion_direction()


func _on_walk_forward_action_released() -> void:
	_walking_input.y = 0.0


func _on_walk_backward_action_pressed() -> void:
	if can_move:
		_walking_input.y = 1.0
		_update_locomotion_direction()


func _on_walk_backward_action_released() -> void:
	_walking_input.y = 0


func _on_walk_left_action_pressed() -> void:
	if can_move:
		_walking_input.x = -1.0
		_update_locomotion_direction()


func _on_walk_left_action_released() -> void:
	_walking_input.x = 0.0


func _on_walk_right_action_pressed() -> void:
	if can_move:
		_walking_input.x = 1.0
		_update_locomotion_direction()


func _on_walk_right_action_released() -> void:
	_walking_input.x = 0.0


func _on_out_of_bounds_player_animation_finished(anim_name: String) -> void:
	if anim_name == "out_of_bounds":
		emit_signal("bounds_escaped")
