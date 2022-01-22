extends Node

const SETTINGS_FILE_PATH := "user://settings.cfg"

var msaa: int
var fxaa: bool

func load_settings(from_path: String = SETTINGS_FILE_PATH) -> int:
	var config_file := ConfigFile.new()
	var error_code := config_file.load(from_path)
	
	Utility.set_framerate(config_file.get_value("performance", "framerate", 90))
	msaa = config_file.get_value("performance", "msaa", Viewport.MSAA_2X)
	fxaa = config_file.get_value("performance", "fxaa", false)
	
	return OK


func save_settings(to_path: String = SETTINGS_FILE_PATH) -> int:
	var config_file := ConfigFile.new()
	
	config_file.set_value("performance", "framerate", Engine.iterations_per_second)
	config_file.set_value("performance", "msaa", msaa)
	config_file.set_value("performance", "fxaa", fxaa)
	
	return config_file.save(to_path)


func apply_to_viewport(viewport: Viewport) -> void:
	viewport.msaa = self.msaa
	viewport.fxaa = self.fxaa
