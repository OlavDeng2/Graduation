extends ARVROrigin

export var max_movement_speed = 5
var left_controller = null
var right_controller = null
var movement_mode = "Joystick"
var movement_direction = null
var movement_speed = null

# Called when the node enters the scene tree for the first time.
func _ready():
	left_controller = get_node("Left_Controller")
	right_controller = get_node("Right_Controller")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _change_movement_mode(movementMode):
	movement_mode = movementMode
	left_controller.movement_mode = movement_mode
	right_controller.movement_mode = movement_mode
	
func _snapturn():
	pass

#this is used for the teleport movement method	
func _teleport():
	pass
	
#This is used for the world rotate movement method
func _rotate_world():
	pass

#Amrswinger movement method
func _armswinger():
	pass

#smooth locomotion
func _smooth_locomotion():
	pass
