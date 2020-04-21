extends ARVROrigin

var player_rigidbody = null
var player_camera = null
var player_collision = null

var dominant_hand = 2
export var max_movement_speed = 5
var left_controller = null
var right_controller = null
var movement_mode = "Smooth"
var movement_direction = null
var movement_speed = null

var has_rotated = false

# Called when the node enters the scene tree for the first time.
func _ready():
	left_controller = get_node("Left_Controller")
	right_controller = get_node("Right_Controller")
	player_rigidbody = get_parent()
	player_camera = get_node("Player_Camera")
	player_collision = get_node("../CollisionShape")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#moves the collider so that it is always where the camera is
	_move_collider()


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
func _armswinger(controller_id, movement_velocity):
	pass


#moves the collider so that it is always where the camera is
func _move_collider():
	#do not move the y axis, the y axis will be handled by the arvr origin to avoid crouching and the likes causing the player to fall through the world
	player_collision.get_transform().basis.x = player_camera.get_transform().basis.x
	player_collision.get_transform().basis.z = player_camera.get_transform().basis.z
