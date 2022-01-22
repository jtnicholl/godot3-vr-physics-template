class_name VRGlove extends Spatial

onready var _tree: AnimationTree = $AnimationTree

var _flattened := false

func _process(delta: float):
	_tree["parameters/blend/blend_amount"] = clamp(_tree["parameters/blend/blend_amount"] \
			 + (delta*-4 if _flattened else delta*4), -1, 0)


func flatten() -> void:
	_flattened = true


func rest() -> void:
	_flattened = false


func grip() -> void:
	pass
