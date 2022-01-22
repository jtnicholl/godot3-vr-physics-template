extends Spatial

func _ready():
	Settings.load_settings()
	var viewport := get_viewport()
	Utility.initialize_openvr(viewport)
	Settings.apply_to_viewport(viewport)


func _exit_tree():
	Settings.save_settings()
	ARVRServer.primary_interface.uninitialize()
