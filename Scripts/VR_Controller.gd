extends ARVRController



export (NodePath) var function_player_rotate = null
export (NodePath) var function_smooth_locomotion = null
export (NodePath) var function_armswinger = null
export (NodePath) var function_teleport = null

var function_player_rotate_node = null
var function_smooth_locomotion_node = null
var function_armswinger_node = null
var function_teleport_node = null

var player_controller = null

export var is_dominant_hand = false

#0 = unkown, 1 = left, 2 = right
export var controller_hand = 0

var local_controller_velocity = Vector3(0,0,0)
var local_prior_controller_position = Vector3(0,0,0)
var local_prior_controller_velocities = []

var global_controller_velocity = Vector3(0,0,0)
var global_prior_controller_position = Vector3(0,0,0)
var global_prior_controller_velocities = []

var held_object = null
var held_object_data = {"mode":RigidBody.MODE_RIGID, "layer":1, "mask":1}

var grab_area
var grab_pos_node

var hand_mesh
var hand_pickup_drop_sound


const CONTROLLER_RUMBLE_FADE_SPEED = 2.0


#Update controls based on dominant hand or not
func update_controls(var current_movement_method):
	#the movement will go on the non dominant hand
	if(!is_dominant_hand):
		get_node(function_player_rotate).enabled = false
		get_node(function_smooth_locomotion).enabled = false
		get_node(function_armswinger).enabled = false
		get_node(function_teleport).enabled = false
		
		
		match current_movement_method:
			1:
				get_node(function_smooth_locomotion).enabled = true
			2:
				get_node(function_armswinger).enabled = true
			3:
				function_teleport_node.enabled = true
	
	#turning will go on the dominant hand, except for if using armswinger
	elif(is_dominant_hand):
		get_node(function_player_rotate).enabled = true
		get_node(function_smooth_locomotion).enabled = false
		get_node(function_armswinger).enabled = false
		get_node(function_teleport).enabled = false
		
		#if the movement mode is armswinger, disable player rotate option.
		if current_movement_method == 2:
			get_node(function_player_rotate).enabled = false
			get_node(function_armswinger).enabled = true
	
	


func _ready():
	player_controller = get_parent()
	controller_hand = get_controller_id()
	
	if(function_player_rotate):
		function_player_rotate_node = get_node(function_player_rotate)
	if(function_smooth_locomotion):
		function_smooth_locomotion_node = get_node(function_smooth_locomotion)
	if(function_armswinger):
		function_armswinger_node = get_node(function_armswinger)
	if(function_teleport):
		function_teleport_node = get_node(function_teleport)

	grab_area = get_node("Area")
	grab_pos_node = get_node("Grab_Pos")

	hand_mesh = get_node("Hand")
	hand_pickup_drop_sound = get_node("AudioStreamPlayer3D")


func _physics_process(delta):
	if rumble > 0:
		rumble -= delta * CONTROLLER_RUMBLE_FADE_SPEED
		if rumble < 0:
			rumble = 0

	if get_is_active() == true:
		_physics_process_update_controller_velocity(delta)
		_physics_process_update_controller_velocity_global(delta)

	if held_object != null:
		var held_scale = held_object.scale
		held_object.global_transform = grab_pos_node.global_transform
		held_object.scale = held_scale


func _physics_process_update_controller_velocity(delta):
	local_controller_velocity = Vector3(0,0,0)

	if local_prior_controller_velocities.size() > 0:
		for vel in local_prior_controller_velocities:
			local_controller_velocity += vel
		local_controller_velocity = local_controller_velocity / local_prior_controller_velocities.size()
		
	var relative_controller_position = (transform.origin - local_prior_controller_position)
	local_controller_velocity += relative_controller_position
	local_prior_controller_velocities.append(relative_controller_position)
	local_prior_controller_position = transform.origin
	local_controller_velocity /= delta;
	if local_prior_controller_velocities.size() > 30:
		local_prior_controller_velocities.remove(0)


func _physics_process_update_controller_velocity_global(delta):
	global_controller_velocity = Vector3(0,0,0)

	if global_prior_controller_velocities.size() > 0:
		for vel in global_prior_controller_velocities:
			global_controller_velocity += vel

		global_controller_velocity = global_controller_velocity / global_prior_controller_velocities.size()
	
	var relative_controller_position = (global_transform.origin - global_prior_controller_position)

	global_controller_velocity += relative_controller_position

	global_prior_controller_velocities.append(relative_controller_position)

	global_prior_controller_position = global_transform.origin

	global_controller_velocity /= delta;

	if global_prior_controller_velocities.size() > 30:
		global_prior_controller_velocities.remove(0)
