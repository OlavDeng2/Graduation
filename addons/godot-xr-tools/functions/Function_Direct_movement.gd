extends Node

# Is this active?
export var enabled = true setget set_enabled, get_enabled

# We don't know the name of the camera node... 
export (NodePath) var camera = null
export (NodePath) var player = null

# and movement
export var max_speed = 5.0
export var drag_factor = 0.1

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

var player_controller = null
var camera_node = null
var velocity = Vector3(0.0, 0.0, 0.0)
onready var collision_shape: CollisionShape = get_node("KinematicBody/CollisionShape")
onready var tail : RayCast = get_node("KinematicBody/Tail")

func set_enabled(new_value):
	enabled = new_value
	if collision_shape:
		collision_shape.disabled = !enabled
	if tail:
		tail.enabled = enabled
	if enabled:
		# make sure our physics process is on
		set_physics_process(true)
	else:
		# we turn this off in physics process just in case we want to do some cleanup
		pass

func get_enabled():
	return enabled

func _ready():
	# origin node should always be the parent of our parent
	player_controller = get_node("../..")
	
	if camera:
		camera_node = get_node(camera)
	# Our properties are set before our children are constructed so just re-issue
	
	collision_shape.disabled = !enabled
	tail.enabled = enabled

func _physics_process(delta):
	if !player_controller:
		return
	
	if !camera_node:
		return
	
	if !enabled:
		set_physics_process(false)
		return
	
	# We should be the child or the controller on which the teleport is implemented
	var controller = get_parent()
	if controller.get_is_active():
		var left_right = controller.get_joystick_axis(0)
		var forwards_backwards = controller.get_joystick_axis(1)
		
		# now we do our movement
		# We start with placing our KinematicBody in the right place
		# by centering it on the camera but placing it on the ground
		var curr_transform = player_controller.kinematicbody.global_transform
		var camera_transform = camera_node.global_transform
		curr_transform.origin = camera_transform.origin
		curr_transform.origin.y = player_controller.global_transform.origin.y
			
		# now we move it slightly back
		var forward_dir = -camera_transform.basis.z
		forward_dir.y = 0.0
		if forward_dir.length() > 0.01:
			curr_transform.origin += forward_dir.normalized() * -0.75 * player_controller.player_radius
		
		player_controller.kinematicbody.global_transform = curr_transform
		
		# Apply our drag
		velocity *= (1.0 - drag_factor)
		
		if ((abs(forwards_backwards) > 0.1 ||  abs(left_right) > 0.1) and tail.is_colliding()):
			var dir_forward = camera_transform.basis.z
			dir_forward.y = 0.0				
			# VR Capsule will strafe left and right
			var dir_right = camera_transform.basis.x;
			dir_right.y = 0.0				
			velocity = (dir_forward * -forwards_backwards + dir_right * left_right).normalized() * delta * max_speed * ARVRServer.world_scale
			
		# apply move and slide to our kinematic body
		velocity = player_controller.kinematicbody.move_and_slide(velocity, Vector3(0.0, 1.0, 0.0))
			
		# now use our new position to move our origin point
		var movement = (player_controller.kinematicbody.global_transform.origin - curr_transform.origin)
		player_controller.global_transform.origin += movement
			
