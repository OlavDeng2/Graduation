extends ARVRController

var movement_mode = "Smooth"
var move_button_down = false

var armswinger_movement_directions = []

var player_controller = null

#0 = unkown, 1 = left, 2 = right
var controller_hand = 0

var controller_velocity = Vector3(0,0,0)
var prior_controller_position = Vector3(0,0,0)
var prior_controller_velocities = []

var global_controller_velocity = Vector3(0,0,0)
var global_prior_controller_position = Vector3(0,0,0)
var global_prior_controller_velocities = []

var held_object = null
var held_object_data = {"mode":RigidBody.MODE_RIGID, "layer":1, "mask":1}

var grab_area
var grab_pos_node

var hand_mesh
var hand_pickup_drop_sound

var teleport_pos = Vector3.ZERO
var teleport_mesh
var teleport_raycast

# A constant to define the dead zone for both the trackpad and the joystick.
# See (http://www.third-helix.com/2013/04/12/doing-thumbstick-dead-zones-right.html)
# for more information on what dead zones are, and how we are using them in this project.
const CONTROLLER_DEADZONE = 0.1

const MOVEMENT_SPEED = 2.5
const ARMSWINGER_SPEED = 1.0

const CONTROLLER_RUMBLE_FADE_SPEED = 2.0

var directional_movement = false


func _ready():
	# Ignore the warnings the from the connect function calls.
	# (We will not need the returned values for this tutorial)
	# warning-ignore-all:return_value_discarded
	player_controller = get_parent()
	controller_hand = get_controller_id()

	move_button_down = false

	teleport_raycast = get_node("RayCast")

	teleport_mesh = get_tree().root.get_node("Game/Teleport_Mesh")

	teleport_mesh.visible = false
	teleport_raycast.visible = false
	
	grab_area = get_node("Area")
	grab_pos_node = get_node("Grab_Pos")

	get_node("Sleep_Area").connect("body_entered", self, "sleep_area_entered")
	get_node("Sleep_Area").connect("body_exited", self, "sleep_area_exited")

	hand_mesh = get_node("Hand")
	hand_pickup_drop_sound = get_node("AudioStreamPlayer3D")

	connect("button_pressed", self, "button_pressed")
	connect("button_release", self, "button_released")


func _physics_process(delta):
	if rumble > 0:
		rumble -= delta * CONTROLLER_RUMBLE_FADE_SPEED
		if rumble < 0:
			rumble = 0

	#this applies only for teleport and smooth locomotion for now
	_move_player(delta)
	_snapturn()

	if get_is_active() == true:
		_physics_process_update_controller_velocity(delta)
		_physics_process_update_controller_velocity_global(delta)

	if held_object != null:
		var held_scale = held_object.scale
		held_object.global_transform = grab_pos_node.global_transform
		held_object.scale = held_scale


func _physics_process_update_controller_velocity(delta):
	controller_velocity = Vector3(0,0,0)

	if prior_controller_velocities.size() > 0:
		for vel in prior_controller_velocities:
			controller_velocity += vel

		controller_velocity = controller_velocity / prior_controller_velocities.size()
	
	#Global transform
	#var relative_controller_position = (global_transform.origin - prior_controller_position)
	#local transform
	var relative_controller_position = (transform.origin - prior_controller_position)

	controller_velocity += relative_controller_position

	prior_controller_velocities.append(relative_controller_position)

	#global transform
	#prior_controller_position = global_transform.origin
	#local transform
	prior_controller_position = transform.origin

	controller_velocity /= delta;

	if prior_controller_velocities.size() > 30:
		prior_controller_velocities.remove(0)


func _physics_process_update_controller_velocity_global(delta):
	global_controller_velocity = Vector3(0,0,0)

	if global_prior_controller_velocities.size() > 0:
		for vel in global_prior_controller_velocities:
			global_controller_velocity += vel

		global_controller_velocity = global_controller_velocity / global_prior_controller_velocities.size()
	
	#Global transform
	var relative_controller_position = (global_transform.origin - global_prior_controller_position)

	global_controller_velocity += relative_controller_position

	global_prior_controller_velocities.append(relative_controller_position)

	#global transform
	global_prior_controller_position = global_transform.origin

	global_controller_velocity /= delta;

	if global_prior_controller_velocities.size() > 30:
		global_prior_controller_velocities.remove(0)


func _snapturn():
	if controller_hand == player_controller.dominant_hand:
		var joystick_x_axis = get_joystick_axis(0)
		if joystick_x_axis < CONTROLLER_DEADZONE and joystick_x_axis > -CONTROLLER_DEADZONE:
			joystick_x_axis = 0
		player_controller.snapturn(joystick_x_axis)

func _move_player(delta):
	if movement_mode == "Smooth":
		if controller_hand != player_controller.dominant_hand:
			var trackpad_vector = Vector2(-get_joystick_axis(1), get_joystick_axis(0))
			smoothLocomotion(delta, trackpad_vector)
	elif movement_mode == "Teleport":
		if controller_hand != player_controller.dominant_hand:
			var trackpad_vector = Vector2(-get_joystick_axis(1), get_joystick_axis(0))
			teleport(trackpad_vector)
	elif movement_mode == "Armswinger":
		if move_button_down == true:
			armswinger(delta)


func button_pressed(button_index):
	if button_index == 15:
		_on_button_pressed_trigger()

	if button_index == 2:
		_on_button_pressed_grab()
		
	if button_index == 1:
		_on_button_pressed_b()


func _on_button_pressed_trigger():
	if held_object != null: 
		if held_object is VR_Interactable_Rigidbody:
			held_object.interact()


func _on_button_pressed_grab():
	if held_object == null:
		_pickup_rigidbody()
	#else:
	#	_throw_rigidbody()
	hand_pickup_drop_sound.play()


func _on_button_pressed_b():
	move_button_down = true
	
	#Empty the armswinger array to get clear data for movement while swinging arms
	armswinger_movement_directions.clear()


func _pickup_rigidbody():
	var rigid_body = null

	var bodies = grab_area.get_overlapping_bodies()
	if len(bodies) > 0:
		for body in bodies:
			if body is RigidBody:
				if !("NO_PICKUP" in body):
					rigid_body = body
					break

	if rigid_body != null:

		held_object = rigid_body

		held_object_data["mode"] = held_object.mode
		held_object_data["layer"] = held_object.collision_layer
		held_object_data["mask"] = held_object.collision_mask

		held_object.mode = RigidBody.MODE_STATIC
		held_object.collision_layer = 0
		held_object.collision_mask = 0

		hand_mesh.visible = false

		if held_object is VR_Interactable_Rigidbody:
			held_object.controller = self
			held_object.picked_up()


func _throw_rigidbody():
	if held_object == null:
		return

	held_object.mode = held_object_data["mode"]
	held_object.collision_layer = held_object_data["layer"]
	held_object.collision_mask = held_object_data["mask"]

	held_object.apply_impulse(Vector3(0, 0, 0), global_controller_velocity)

	if held_object is VR_Interactable_Rigidbody:
		held_object.dropped()
		held_object.controller = null

	held_object = null
	hand_mesh.visible = true


func button_released(button_index):
	if button_index == 1:
		_on_button_released_b()
	if button_index == 2:
		_on_button_released_grab()


func _on_button_released_b():
	move_button_down = false


func _on_button_released_grab():
	if held_object != null:
		_throw_rigidbody()
	hand_pickup_drop_sound.play()


func sleep_area_entered(body):
	if "can_sleep" in body:
		body.can_sleep = false
		body.sleeping = false


func sleep_area_exited(body):
	if "can_sleep" in body:
		# Allow the CollisionBody to sleep by setting the "can_sleep" variable to true
		body.can_sleep = true


func smoothLocomotion(delta, trackpad_vector):
	if trackpad_vector.length() < CONTROLLER_DEADZONE:
		trackpad_vector = Vector2(0,0)
	else:
		trackpad_vector = trackpad_vector.normalized() * ((trackpad_vector.length() - CONTROLLER_DEADZONE) / (1 - CONTROLLER_DEADZONE))
	
	var forward_direction = get_parent().get_node("Player_Camera").global_transform.basis.z.normalized()
	var right_direction = get_parent().get_node("Player_Camera").global_transform.basis.x.normalized()
	
	var movement_vector = (trackpad_vector).normalized()
	
	var movement_forward = forward_direction * movement_vector.x * delta * MOVEMENT_SPEED
	var movement_right = right_direction * movement_vector.y * delta * MOVEMENT_SPEED
	
	movement_forward.y = 0
	movement_right.y = 0
	
	if (movement_right.length() > 0 or movement_forward.length() > 0):
		get_parent().global_translate(movement_right + movement_forward)
		directional_movement = true
	else:
		directional_movement = false


func teleport(trackpad_vector):
	if trackpad_vector.length() > CONTROLLER_DEADZONE:
		if teleport_mesh.visible == false:
			teleport_mesh.visible = true
			teleport_raycast.visible = true
					
		teleport_raycast.force_raycast_update()
		if teleport_raycast.is_colliding():
			if teleport_raycast.get_collider() is StaticBody:
				if teleport_raycast.get_collision_normal().y >= 0.85:
					teleport_pos = teleport_raycast.get_collision_point()
					teleport_mesh.global_transform.origin = teleport_pos
	
	if trackpad_vector.length() < CONTROLLER_DEADZONE:
		if teleport_pos != null and teleport_mesh.visible == true:
			var camera_offset = get_parent().get_node("Player_Camera").global_transform.origin - get_parent().global_transform.origin
			camera_offset.y = 0
			get_parent().global_transform.origin = teleport_pos - camera_offset
			teleport_mesh.visible = false
			teleport_raycast.visible = false
			teleport_pos = null


func armswinger(delta):
	var movement_forward = Vector3(0, 0, 0)
	#get direction of controllers, make it negative otherwise we get the wrong direction
	var direction = -get_global_transform().basis.z.normalized()#-get_transform().basis.z.normalized()
	#translate the directions into top down 2d
	direction.y = 0
	#add the speed for the movement
	movement_forward = direction * delta * ARMSWINGER_SPEED
	#move player in direction of controllers at a set speed when button is pressed
	get_parent().global_translate(movement_forward)
	
	#get velocity of controllers
	movement_forward = direction * controller_velocity.length() * delta
	armswinger_movement_directions.append(movement_forward)
	
	#Get the average movement for the last second to make a more "forgiving" armswinger
	var average_movement = Vector3(0,0,0)
	for i in armswinger_movement_directions:
		average_movement += movement_forward
	average_movement = average_movement/armswinger_movement_directions.size()
	
	#move the player in the direction that the controller is pointing
	get_parent().global_translate(average_movement)
