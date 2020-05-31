extends ARVROrigin


export (NodePath) var player_camera = null

export var player_height = 0.9

var dominant_hand = 2
var left_controller = null
var right_controller = null
var movement_mode = "Smooth"

var snapturn_amount = 45 #in degrees
var has_rotated = false

# size of our player
export var player_radius = 0.4 setget set_player_radius, get_player_radius

# to combat motion sickness we'll 'step' our left/right turning
export var smooth_rotation = false
export var smooth_turn_speed = 2.0
export var step_turn_delay = 0.2
export var step_turn_angle = 20.0

# and movement
export var max_speed = 5.0
export var drag_factor = 0.1
export var gravity_scale = 9.81

# enum our buttons, should find a way to put this more central
enum Buttons {
	VR_BUTTON_BY = 1,
	VR_GRIP = 2,
	VR_BUTTON_3 = 3,
	VR_BUTTON_4 = 4,
	VR_BUTTON_5 = 5,
	VR_BUTTON_6 = 6,
	VR_BUTTON_AX = 7,
	VR_BUTTON_8 = 8,
	VR_BUTTON_9 = 9,
	VR_BUTTON_10 = 10,
	VR_BUTTON_11 = 11,
	VR_BUTTON_12 = 12,
	VR_BUTTON_13 = 13,
	VR_PAD = 14,
	VR_TRIGGER = 15
}

var turn_step = 0.0
var camera_node = null
var velocity = Vector3(0.0, 0.0, 0.0)
var gravity = -30.0
onready var collision_shape: CollisionShape = get_node("KinematicBody/CollisionShape")
onready var raycast : RayCast = get_node("KinematicBody/RayCast")

# Set our collision layer (need to change this once we can add the proper UI)
export  (int, FLAGS, "Layer 1", "Layer 2", "Layer 3", "Layer 4", "Layer 5", "Layer 6", "Layer 7", "Layer 8", "Layer 9", "Layer 10", "Layer 11", "Layer 12", "Layer 13", "Layer 14", "Layer 15", "Layer 16", "Layer 17", "Layer 18", "Layer 19", "Layer 20") var collision_layer = 1 setget set_collision_layer, get_collision_layer

# Set our collision mask (need to change this once we can add the proper UI)
export  (int, FLAGS, "Layer 1", "Layer 2", "Layer 3", "Layer 4", "Layer 5", "Layer 6", "Layer 7", "Layer 8", "Layer 9", "Layer 10", "Layer 11", "Layer 12", "Layer 13", "Layer 14", "Layer 15", "Layer 16", "Layer 17", "Layer 18", "Layer 19", "Layer 20") var collision_mask = 1022 setget set_collision_mask, get_collision_mask

func set_collision_layer(new_layer):
	collision_layer = new_layer
	if $KinematicBody:
		$KinematicBody.collision_layer = collision_layer

func get_collision_layer():
	return collision_layer

func set_collision_mask(new_mask):
	collision_mask = new_mask
	if $KinematicBody:
		$KinematicBody.collision_mask = collision_mask
		$KinematicBody/RayCast.collision_mask = collision_mask

func get_collision_mask():
	return collision_mask

func get_player_radius():
	return player_radius

func set_player_radius(p_radius):
	player_radius = p_radius

func _ready():
		
	if player_camera:
		camera_node = get_node(player_camera)
	else:
		# see if we can find our default
		camera_node = self.get_node('ARVRCamera')
	
	# Our properties are set before our children are constructed so just re-issue
	set_collision_layer(collision_layer)
	set_collision_mask(collision_mask)
	set_player_radius(player_radius)
	
	
	left_controller = get_node("Left_Controller")
	right_controller = get_node("Right_Controller")
	player_camera = get_node("Player_Camera")
	raycast = get_node("KinematicBody/RayCast")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	# Adjust the height of our player according to our camera position
	player_height = camera_node.transform.origin.y + player_radius
	if player_height < player_radius:
		# not smaller than this
		player_height = player_radius
	
	collision_shape.shape.radius = player_radius
	collision_shape.shape.height = player_height - (player_radius * 2.0)
	collision_shape.transform.origin.y = (player_height / 2.0)
		
	################################################################
	# now we do our movement
	# We start with placing our KinematicBody in the right place
	# by centering it on the camera but placing it on the ground
	var curr_transform = $KinematicBody.global_transform
	var camera_transform = camera_node.global_transform
	curr_transform.origin = camera_transform.origin
	curr_transform.origin.y = self.global_transform.origin.y
	
	# now we move it slightly back
	var forward_dir = -camera_transform.basis.z
	forward_dir.y = 0.0
	if forward_dir.length() > 0.01:
		curr_transform.origin += forward_dir.normalized() * -0.75 * player_radius
	
	$KinematicBody.global_transform = curr_transform
	
	# we'll handle gravity separately
	var gravity_velocity = Vector3(0.0, velocity.y, 0.0)
	velocity.y = 0.0
	
	# Apply our drag
	velocity *= (1.0 - drag_factor)
	
	
	# apply move and slide to our kinematic body
	velocity = $KinematicBody.move_and_slide(velocity, Vector3(0.0, 1.0, 0.0))
	
	# apply our gravity
	gravity_velocity.y += gravity * delta
	gravity_velocity = $KinematicBody.move_and_slide(gravity_velocity, Vector3(0.0, 1.0, 0.0))
	velocity.y = gravity_velocity.y
	
	# now use our new position to move our origin point
	var movement = ($KinematicBody.global_transform.origin - curr_transform.origin)
	self.global_transform.origin += movement

	# Return this back to where it was so we can use its collision shape for other things too
	# $KinematicBody.global_transform.origin = curr_transform.origin

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



