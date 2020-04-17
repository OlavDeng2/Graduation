extends ARVROrigin

export var max_movement_speed = 5
var left_controller = null
var right_controller = null
var movement_mode = "Joystick"
var movement_direction = null
var movement_speed = null

var has_rotated = false

# Called when the node enters the scene tree for the first time.
func _ready():
	left_controller = get_node("Left_Controller")
	right_controller = get_node("Right_Controller")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _change_movement_mode(currentMovementMode):
	if currentMovementMode == "Teleport":
		movement_mode = "Smooth"
	if currentMovementMode == "Smooth":
		movement_mode = "Armswinger"
	if currentMovementMode == "Armswinger":
		movement_mode = "Teleport"
		
	left_controller.movement_mode = movement_mode
	right_controller.movement_mode = movement_mode


func snapturn(direction):
	if !has_rotated:
		if direction == 0:
			return
		elif direction < 0:
			#turn right 25 degrees
			rotate_y(45)
			has_rotated = true	
		elif direction > 0:
			#turn left 25 degrees
			rotate_y(-45)
			has_rotated = true

	if has_rotated:
		if direction == 0:
			has_rotated = false


#this is used for the teleport movement method	
func _teleport():
	pass
	
#This is used for the world rotate movement method
func _rotate_world():
	pass


#smooth locomotion
func _smooth_locomotion():
	pass

#Amrswinger movement method
func _armswinger():
	pass
