class_name GrabResult extends Object

var pickup: Pickup
var grab_point: Spatial

func _init(pickup: Pickup, grab_point: Spatial):
	self.pickup = pickup
	self.grab_point = grab_point
