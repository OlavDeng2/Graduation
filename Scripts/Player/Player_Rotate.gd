extends Node

# Is this active?
export var enabled = true setget set_enabled, get_enabled

# We don't know the name of the camera node... 
export (NodePath) var camera = null
export (NodePath) var player = null

# to combat motion sickness we'll 'step' our left/right turning
export var smooth_turn = false
export var smooth_turn_speed = 2.0
export var snap_turn_angle = 20.0
export var joystick_deadzone = 0.1 

var has_turned = false
var camera_node = null
var player_controller = null


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
	
	player_controller.Buttons.VR_Grip
	
	# We should be the child or the controller on which the teleport is implemented
	var controller = get_parent()
	if controller.get_is_active():
		var left_right = controller.get_joystick_axis(0)
		
		#smooth turn
		if smooth_turn:
			# we rotate around our Camera, but we adjust our origin, so we need a little bit of trickery
			var t1 = Transform()
			var t2 = Transform()
			var rot = Transform()
			
			t1.origin = -camera_node.transform.origin
			t2.origin = camera_node.transform.origin
			rot = rot.rotated(Vector3(0.0, -1.0, 0.0), smooth_turn_speed * delta * left_right)
			player_controller.transform *= t2 * rot * t1
		
		#Snapturn
		else:
			#reset whether the player has rotated
			if has_turned and abs(left_right) < joystick_deadzone:
				has_turned = false
			
			#Only rotate if the joystick has been reset
			if !has_turned and abs(left_right) > joystick_deadzone:
				has_turned = true
				
				# we rotate around our Camera, but we adjust our origin, so we need a little bit of trickery
				var t1 = Transform()
				var t2 = Transform()
				var rot = Transform()
					
				t1.origin = -camera_node.transform.origin
				t2.origin = camera_node.transform.origin
				
				if (left_right > joystick_deadzone):
					rot = rot.rotated(Vector3(0.0, -1.0, 0.0), snap_turn_angle * PI / 180.0)
				elif(left_right < -joystick_deadzone):
					rot = rot.rotated(Vector3(0.0, 1.0, 0.0), snap_turn_angle * PI / 180.0)
					
				player_controller.transform *= t2 * rot * t1
