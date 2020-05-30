extends ARVROrigin

var player_camera = null

export var player_height = 0.9
var raycast = null

var dominant_hand = 2
var left_controller = null
var right_controller = null
var movement_mode = "Smooth"

var snapturn_amount = 45 #in degrees
var has_rotated = false

# Called when the node enters the scene tree for the first time.
func _ready():
	left_controller = get_node("Left_Controller")
	right_controller = get_node("Right_Controller")
	player_camera = get_node("Player_Camera")
	raycast = get_node("KinematicBody/RayCast")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#moves the collider so that it is always where the camera is
	#_ground_collider()
	pass

func _change_movement_mode(currentMovementMode):
	if currentMovementMode == "Teleport":
		movement_mode = "Smooth"
	elif currentMovementMode == "Smooth":
		movement_mode = "Armswinger"
	elif currentMovementMode == "Armswinger":
		movement_mode = "Teleport"
	else:
		movement_mode = "Smooth"
		print_debug(currentMovementMode)
	
		
	left_controller.movement_mode = movement_mode
	right_controller.movement_mode = movement_mode


func snapturn(direction):
	if !has_rotated:
		if direction == 0:
			return
		elif direction < 0:
			#turn right 45 degrees
			rotate_y(snapturn_amount)
			has_rotated = true	
		elif direction > 0:
			#turn left 45 degrees
			rotate_y(-snapturn_amount)
			has_rotated = true

	if has_rotated:
		if direction == 0:
			has_rotated = false



