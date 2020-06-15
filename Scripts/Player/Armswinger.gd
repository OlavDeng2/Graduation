extends Node

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

# Is this active?
export var enabled = true setget set_enabled, get_enabled

# We don't know the name of the camera node... 
export (NodePath) var camera = null
export (NodePath) var player = null
export (NodePath) var vr_controller = null
 
# and movement
export var max_speed = 5.0
export var min_speed = 1.0
export var drag_factor = 0.1
export var headset_direction = true;

export var armswinger_button = Buttons.VR_BUTTON_BY

var player_controller = null
var camera_node = null
var velocity = Vector3(0.0, 0.0, 0.0)


var armswinger_speeds = []

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
	# origin node should always be the parent of our parent
	player_controller = get_node("../..")
	
	vr_controller = get_node("../")
	
	if camera:
		camera_node = get_node(camera)
	# Our properties are set before our children are constructed so just re-issue


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
		
		#Get some player transforms
		var curr_transform = player_controller.kinematicbody.global_transform
		var camera_transform = camera_node.global_transform
		
		# Apply our drag
		velocity *= (1.0 - drag_factor)
		
		if controller.is_button_pressed(armswinger_button) and player_controller.raycast.is_colliding():
			#Get the current local controller speed
			var current_controller_speed =  vr_controller.local_controller_velocity.length()
			
			#add controller speed to the list of average speeds
			armswinger_speeds.append(current_controller_speed)
			
			#if array speed is larger than 1second worth of data, remove the first one
			#TODO: make it based on 1 second instead of just the amount of frames
			if armswinger_speeds.size() > 120:
				armswinger_speeds.remove(0)
			#add all speeds together
			var total_speed = 0
			for i in armswinger_speeds:
				total_speed += i
			#get average speed
			var average_controller_speed = total_speed/armswinger_speeds.size()
			
			#apply the velocity based on either headset direction or controller direction
			#Direction based on headset orientation
			if headset_direction:
				var dir_forward = camera_transform.basis.z
				dir_forward.y = 0.0	
				velocity = (-dir_forward).normalized() * average_controller_speed * delta * max_speed * ARVRServer.world_scale
				
				#Check if the speed is lower than the minimum velocity, if it is, apply the minimum velocity instead
				var min_velocity = (-dir_forward).normalized() * delta * min_speed * ARVRServer.world_scale
				if(min_velocity.length() > velocity.length()):
					velocity = min_velocity
					
			#Direction based on controller orientation
			else:
				var dir_forward = controller.global_transform.basis.z
				dir_forward.y = 0.0				
				velocity = (-dir_forward).normalized() * average_controller_speed * delta * max_speed * ARVRServer.world_scale
				
				#Check if the speed is lower than the minimum velocity, if it is, apply the minimum velocity instead
				var min_velocity = (-dir_forward).normalized() * delta * max_speed * ARVRServer.world_scale
				if(min_velocity.length() > velocity.length()):
					velocity = min_velocity
		
		#clear the armswinger speeds array otherwise the velocity will be remembered
		elif !controller.is_button_pressed(armswinger_button):
			armswinger_speeds.clear()
			
		# apply move and slide to our kinematic body
		velocity = player_controller.kinematicbody.move_and_slide(velocity, Vector3(0.0, 1.0, 0.0))
			
		# now use our new position to move our origin point
		var movement = (player_controller.kinematicbody.global_transform.origin - curr_transform.origin)
		player_controller.global_transform.origin += movement
