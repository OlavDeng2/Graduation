extends ARVROrigin

var player_rigidbody = null
var player_camera = null
var player_collision = null
var is_falling = false

export var player_height = 0.9
var raycast = null

var dominant_hand = 2
export var max_movement_speed = 5
var left_controller = null
var right_controller = null
var movement_mode = "Smooth"
var movement_direction = null
var movement_speed = null

#armswinger stuff
var left_controller_armswinger = false
var right_controller_armswinger = false
var left_controller_movement = null
var right_controller_movement = null

var snapturn_amount = 45 #in degrees
var has_rotated = false

# Called when the node enters the scene tree for the first time.
func _ready():
	left_controller = get_node("Left_Controller")
	right_controller = get_node("Right_Controller")
	player_rigidbody = get_parent()
	player_camera = get_node("Player_Camera")
	player_collision = get_node("../CollisionShape")
	raycast = get_node("Player_Camera/RayCast")

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


func _ground_collider():
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var col_point = raycast.get_collision_point()
		
		#calculate height raycast hits
		var height = player_rigidbody.get_global_transform().origin.y - col_point.y#player_camera.get_global_transform().origin.y - col_point.y
		
		print_debug(height)
		#is the player standing or falling
		if height <= 0:#player_height:
			#disable gravity
			player_rigidbody.gravity_scale = 0
			player_rigidbody.axis_lock_linear_y = true
			
			#match the colider with where the player is standing
			#player_collision.transform.basis.x = player_camera.get_transform().basis.x
			#player_collision.transform.basis.z = player_camera.get_transform().basis.z
			
			if height < 0 and is_falling:#player_height:
				print_debug("setting height properly")
				#set height above the ground
				var new_player_pos = Vector3(col_point.x, col_point.y, col_point.z)
				var new_transform : Transform
				new_transform.origin = new_player_pos
				#player_collision.set_global_transform(new_transform)
				#player_rigidbody.global_transform.basis.y = new_transform.basis.y
			
			is_falling = false


		#player is falling
		elif height > 0:#player_height:
			#enable gravity
			player_rigidbody.gravity_scale = 1
			player_rigidbody.axis_lock_linear_y = false
			
			if !is_falling:
				player_rigidbody.set_axis_velocity(Vector3(0, 0.1, 0))
			is_falling = true


	elif !raycast.is_colliding():
		print_debug("no ground found")
		#if is not colliding, enable gravity
		player_rigidbody.gravity_scale = 1
		player_rigidbody.axis_lock_linear_y = false
		
		if !is_falling:
			player_rigidbody.set_axis_velocity(Vector3(0, 0.1, 0))
		is_falling = true
