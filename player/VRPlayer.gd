class_name VRPlayer extends ARVROrigin

export(bool) var can_move := true
export(float) var impulse_multiplier := 0.2

onready var _left_controller: VRController = $LeftController
onready var _right_controller: VRController = $RightController
onready var _left_hand: VRHand = $LeftHand
onready var _right_hand: VRHand = $RightHand
onready var _teleporter: Teleporter = $LeftController/Teleporter
onready var _camera: ARVRCamera = $Camera

var _left_pickup: Pickup = null
var _right_pickup: Pickup = null

func position_feet(global_position: Vector3) -> void:
	var camera_offset := _camera.global_transform.origin - global_transform.origin
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


func _try_grab(tracker_hand: int) -> void:
	var controller := _left_controller if tracker_hand == \
			ARVRPositionalTracker.TRACKER_LEFT_HAND else _right_controller
	var hand := _left_hand  if tracker_hand == \
			ARVRPositionalTracker.TRACKER_LEFT_HAND else _right_hand
	var result := controller.try_grab()
	if result.pickup != null:
		hand.global_transform = result.grab_point.global_transform
		hand.translate_object_local(controller.grab_offset)
		result.pickup.pick_up(hand)
		if tracker_hand == ARVRPositionalTracker.TRACKER_LEFT_HAND:
			_left_pickup = result.pickup
		else:
			_right_pickup = result.pickup
	result.free()


func _on_teleport_action_pressed():
	if can_move:
		_teleporter.press()


func _on_teleport_action_released():
	_teleporter.release()


func _on_teleporter_teleported(global_position: Vector3):
	if can_move:
		position_feet(global_position)


func _on_turn_left_action_pressed():
	rotate_head(-PI/4)


func _on_turn_right_action_pressed():
	rotate_head(PI/4)


func _on_grab_left_action_pressed():
	call_deferred("_try_grab", ARVRPositionalTracker.TRACKER_LEFT_HAND)


func _on_grab_left_action_released():
	if is_instance_valid(_left_pickup):
		_left_pickup.release($LeftHand.velocity * impulse_multiplier)
	_left_pickup = null


func _on_grab_right_action_pressed():
	call_deferred("_try_grab", ARVRPositionalTracker.TRACKER_RIGHT_HAND)


func _on_grab_right_action_released():
	if is_instance_valid(_right_pickup):
		_right_pickup.release($RightHand.velocity * impulse_multiplier)
	_right_pickup = null
