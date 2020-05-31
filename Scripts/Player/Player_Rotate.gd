extends Node

# Is this active?
export var enabled = true setget set_enabled, get_enabled

# We don't know the name of the camera node... 
export (NodePath) var camera = null
export (NodePath) var player = null

# to combat motion sickness we'll 'step' our left/right turning
export var smooth_rotation = false
export var smooth_turn_speed = 2.0
export var snap_turn_delay = 0.2
export var snap_turn_angle = 20.0

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
var player_controller


func set_enabled(new_value):
	enabled = new_value
	if enabled:
		# make sure our physics process is on
		set_physics_process(true)
	else:
		# we turn this off in physics process just in case we want to do some cleanup
		pass

func get_enabled():
	return enabled

func _ready():
	if player:
		player_controller = get_node(player)
	if(!player):
		# origin node should always be the parent of our parent
		player_controller = get_node("../..")
	
	if camera:
		camera_node = get_node(camera)	
	else:
		# see if we can find our default
		camera_node = get_node(player_controller.player_camera)


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
		

		if smooth_rotation:
			# we rotate around our Camera, but we adjust our origin, so we need a little bit of trickery
			var t1 = Transform()
			var t2 = Transform()
			var rot = Transform()
			
			t1.origin = -camera_node.transform.origin
			t2.origin = camera_node.transform.origin
			rot = rot.rotated(Vector3(0.0, -1.0, 0.0), smooth_turn_speed * delta * left_right)
			player_controller.transform *= t2 * rot * t1
			
			# reset turn step, doesn't apply
			turn_step = 0.0
		else:
			if left_right > 0.0:
				if turn_step < 0.0:
					# reset step
					turn_step = 0
				
				turn_step += left_right * delta
			else:
				if turn_step > 0.0:
					# reset step
					turn_step = 0
				
				turn_step += left_right * delta
			
			if abs(turn_step) > snap_turn_delay:
				# we rotate around our Camera, but we adjust our origin, so we need a little bit of trickery
				var t1 = Transform()
				var t2 = Transform()
				var rot = Transform()
					
				t1.origin = -camera_node.transform.origin
				t2.origin = camera_node.transform.origin
				
				# Rotating
				while abs(turn_step) > snap_turn_delay:
					if (turn_step > 0.0):
						rot = rot.rotated(Vector3(0.0, -1.0, 0.0), snap_turn_angle * PI / 180.0)
						turn_step -= snap_turn_delay
					else:
						rot = rot.rotated(Vector3(0.0, 1.0, 0.0), snap_turn_angle * PI / 180.0)
						turn_step += snap_turn_delay
						
				player_controller.transform *= t2 * rot * t1
	else:
		# reset turn step, no longer turning
		turn_step = 0.0
