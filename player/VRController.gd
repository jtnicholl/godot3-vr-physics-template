class_name VRController extends ARVRController


onready var grab_offset: Vector3 = -($GrabRange as Area).transform.origin

onready var _mesh := $Mesh as MeshInstance
onready var _grab_range := $GrabRange as Area


func show_mesh() -> void:
	_mesh.show()


func hide_mesh() -> void:
	_mesh.hide()


func update_mesh() -> void:
	var ovr_render_model := preload("res://addons/godot-openvr/OpenVRRenderModel.gdns").new()
	var controller_name := get_controller_name().substr(0, get_controller_name().length() - 2)
	if ovr_render_model.load_model(controller_name):
		_mesh.mesh = ovr_render_model
	elif ovr_render_model.load_model("generic_controller"):
		_mesh.mesh = ovr_render_model


func try_grab(max_distance := INF) -> GrabResult:
	var closest_grabbable: Grabbable = null
	var closest_point: Spatial = null
	var closest_distance := max_distance
	for current_body in _grab_range.get_overlapping_bodies():
		if not (current_body is Grabbable):
			continue
		for current_point in current_body.grab_points:
			var current_distance := \
					(current_point as Spatial).global_transform.origin \
					.distance_squared_to(self.global_transform.origin)
			if _compare(current_point, current_distance, closest_point, closest_distance):
				closest_grabbable = current_body
				closest_point = current_point
				closest_distance = current_distance
	return GrabResult.new(closest_grabbable, closest_point)


func _compare(point_a: Spatial, distance_a: float, point_b: Spatial, distance_b: float) -> bool:
	if is_equal_approx(distance_a, distance_b):
		var controller_quat := self.global_transform.basis.get_rotation_quat()
		var quat_a := point_a.global_transform.basis.get_rotation_quat()
		var quat_b := point_b.global_transform.basis.get_rotation_quat()
		return quat_a.angle_to(controller_quat) < quat_b.angle_to(controller_quat)
	elif distance_a < distance_b:
		return true
	else:
		return false


func _on_MeshUpdateTimer_timeout():
	update_mesh()
	if is_instance_valid(_mesh.mesh):
		$MeshUpdateTimer.queue_free()
