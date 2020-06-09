extends ARVRController

var movement_mode = "Smooth"
var move_button_down = false

var is_moving = false

var player_controller = null

#0 = unkown, 1 = left, 2 = right
var controller_hand = 0

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

var teleport_pos = Vector3.ZERO
var teleport_mesh
var teleport_raycast

# A constant to define the dead zone for both the trackpad and the joystick.
const CONTROLLER_DEADZONE = 0.1

const MOVEMENT_SPEED = 3.0

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

	#get_node("Sleep_Area").connect("body_entered", self, "sleep_area_entered")
	#get_node("Sleep_Area").connect("body_exited", self, "sleep_area_exited")

	hand_mesh = get_node("Hand")
	hand_pickup_drop_sound = get_node("AudioStreamPlayer3D")

	#connect("button_pressed", self, "button_pressed")
	#connect("button_release", self, "button_released")


func _physics_process(delta):
	if rumble > 0:
		rumble -= delta * CONTROLLER_RUMBLE_FADE_SPEED
		if rumble < 0:
			rumble = 0

	#this applies only for teleport and smooth locomotion for now
	#_move_player(delta)

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
	
	#Global transform
	#var relative_controller_position = (global_transform.origin - prior_controller_position)
	#local transform
	var relative_controller_position = (transform.origin - local_prior_controller_position)

	local_controller_velocity += relative_controller_position

	local_prior_controller_velocities.append(relative_controller_position)

	#global transform
	#prior_controller_position = global_transform.origin
	#local transform
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
	
	#Global transform
	var relative_controller_position = (global_transform.origin - global_prior_controller_position)

	global_controller_velocity += relative_controller_position

	global_prior_controller_velocities.append(relative_controller_position)

	#global transform
	global_prior_controller_position = global_transform.origin

	global_controller_velocity /= delta;

	if global_prior_controller_velocities.size() > 30:
		global_prior_controller_velocities.remove(0)

#func _move_player(delta):
#	if movement_mode == "Smooth":
#		return
#	elif movement_mode == "Teleport":
#		if controller_hand != player_controller.dominant_hand:
#			var trackpad_vector = Vector2(-get_joystick_axis(1), get_joystick_axis(0))
#			teleport(trackpad_vector)
#	elif movement_mode == "Armswinger":
#		return


#func button_pressed(button_index):
#	if button_index == 15:
#		_on_button_pressed_trigger()

#	if button_index == 2:
#		_on_button_pressed_grab()
		
#	if button_index == 1:
#		_on_button_pressed_b()


#func _on_button_pressed_trigger():
#	if held_object != null: 
#		if held_object is VR_Interactable_Rigidbody:
#			held_object.interact()


#func _on_button_pressed_grab():
#	if held_object == null:
#		_pickup_rigidbody()
	#else:
	#	_throw_rigidbody()
#	hand_pickup_drop_sound.play()


#func _on_button_pressed_b():
#	move_button_down = true


#func _pickup_rigidbody():
#	var rigid_body = null

#	var bodies = grab_area.get_overlapping_bodies()
#	if len(bodies) > 0:
#		for body in bodies:
#			if body is RigidBody:
#				if !("NO_PICKUP" in body):
#					rigid_body = body
#					break

#	if rigid_body != null:

#		held_object = rigid_body

#		held_object_data["mode"] = held_object.mode
#		held_object_data["layer"] = held_object.collision_layer
#		held_object_data["mask"] = held_object.collision_mask

#		held_object.mode = RigidBody.MODE_STATIC
#		held_object.collision_layer = 0
#		held_object.collision_mask = 0

#		hand_mesh.visible = false

#		if held_object is VR_Interactable_Rigidbody:
#			held_object.controller = self
#			held_object.picked_up()


#func _throw_rigidbody():
#	if held_object == null:
#		return

#	held_object.mode = held_object_data["mode"]
#	held_object.collision_layer = held_object_data["layer"]
#	held_object.collision_mask = held_object_data["mask"]

#	held_object.apply_impulse(Vector3(0, 0, 0), global_controller_velocity)

#	if held_object is VR_Interactable_Rigidbody:
#		held_object.dropped()
#		held_object.controller = null

#	held_object = null
#	hand_mesh.visible = true


#func button_released(button_index):
#	if button_index == 1:
#		_on_button_released_b()
#	if button_index == 2:
#		_on_button_released_grab()


#func _on_button_released_b():
#	move_button_down = false
	
	#Simple to slow down the player once they stop armswinging
	#player_controller.player_rigidbody.linear_velocity = Vector3(0,0,0)
	

#func _on_button_released_grab():
#	if held_object != null:
#		_throw_rigidbody()
#	hand_pickup_drop_sound.play()


#func sleep_area_entered(body):
#	if "can_sleep" in body:
#		body.can_sleep = false
#		body.sleeping = false


#func sleep_area_exited(body):
#	if "can_sleep" in body:
		# Allow the CollisionBody to sleep by setting the "can_sleep" variable to true
#		body.can_sleep = true
		

#func teleport(trackpad_vector):
#	if trackpad_vector.length() > CONTROLLER_DEADZONE:
#		if teleport_mesh.visible == false:
#			teleport_mesh.visible = true
#			teleport_raycast.visible = true
#					
#		teleport_raycast.force_raycast_update()
#		if teleport_raycast.is_colliding():
#			if teleport_raycast.get_collider() is StaticBody:
#				if teleport_raycast.get_collision_normal().y >= 0.85:
#					teleport_pos = teleport_raycast.get_collision_point()
#					teleport_mesh.global_transform.origin = teleport_pos
	
#	if trackpad_vector.length() < CONTROLLER_DEADZONE:
#		if teleport_pos != null and teleport_mesh.visible == true:
#			var camera_offset = get_parent().get_node("Player_Camera").global_transform.origin - get_parent().global_transform.origin
#			camera_offset.y = 0
#			player_controller.global_transform.origin = teleport_pos - camera_offset
#			teleport_mesh.visible = false
#			teleport_raycast.visible = false
#			teleport_pos = null
