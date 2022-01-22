class_name Utility

static func initialize_openvr(viewport: Viewport) -> bool:
	var openvr_config := preload("res://addons/godot-openvr/OpenVRConfig.gdns").new()
	openvr_config.default_action_set = "/actions/godot"
	var vr_interface := ARVRServer.find_interface("OpenVR")
	if is_instance_valid(vr_interface) && vr_interface.initialize():
		viewport.size = vr_interface.get_render_targetsize()
		viewport.arvr = true
		OS.vsync_enabled = false
		return true
	else:
		return false


static func set_framerate(framerate: int) -> void:
	Engine.iterations_per_second = framerate
	Engine.target_fps = framerate
