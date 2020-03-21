extends ARVRController

var controller_velocity = Vector3(0,0,0)
var prior_controller_position = Vector3(0,0,0)
var prior_controller_velocities = []

var held_object = null
var held_object_data = {"mode":RigidBody.MODE_RIGID, "layer":1, "mask":1}

var grab_area
var grab_raycast

var grab_mode = "AREA"
var grab_pos_node

var hand_mesh
var hand_pickup_drop_sound

var teleport_pos = Vector3.ZERO
var teleport_mesh
var teleport_button_down
var teleport_raycast

# A constant to define the dead zone for both the trackpad and the joystick.
# See (http://www.third-helix.com/2013/04/12/doing-thumbstick-dead-zones-right.html)
# for more information on what dead zones are, and how we are using them in this project.
const CONTROLLER_DEADZONE = 0.65

const MOVEMENT_SPEED = 1.5

const CONTROLLER_RUMBLE_FADE_SPEED = 2.0

var directional_movement = false


func _ready():
	# Ignore the warnings the from the connect function calls.
	# (We will not need the returned values for this tutorial)
	# warning-ignore-all:return_value_discarded

	teleport_raycast = get_node("RayCast")

	teleport_mesh = get_tree().root.get_node("Game/Teleport_Mesh")

	teleport_button_down = false
	teleport_mesh.visible = false
	teleport_raycast.visible = false

	grab_area = get_node("Area")
	grab_raycast = get_node("Grab_Cast")
	grab_pos_node = get_node("Grab_Pos")

	grab_mode = "AREA"
	grab_raycast.visible = false

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

	if teleport_button_down == true:
		teleport_raycast.force_raycast_update()
		if teleport_raycast.is_colliding():
			if teleport_raycast.get_collider() is StaticBody:
				if teleport_raycast.get_collision_normal().y >= 0.85:
					teleport_pos = teleport_raycast.get_collision_point()
					teleport_mesh.global_transform.origin = teleport_pos


	if get_is_active() == true:
		_physics_process_update_controller_velocity(delta)

	if held_object != null:
		var held_scale = held_object.scale
		held_object.global_transform = grab_pos_node.global_transform
		held_object.scale = held_scale

	_physics_process_directional_movement(delta);


func _physics_process_update_controller_velocity(delta):
	controller_velocity = Vector3(0,0,0)

	if prior_controller_velocities.size() > 0:
		for vel in prior_controller_velocities:
			controller_velocity += vel

		controller_velocity = controller_velocity / prior_controller_velocities.size()

	var relative_controller_position = (global_transform.origin - prior_controller_position)

	controller_velocity += relative_controller_position

	prior_controller_velocities.append(relative_controller_position)

	prior_controller_position = global_transform.origin

	controller_velocity /= delta;

	if prior_controller_velocities.size() > 30:
		prior_controller_velocities.remove(0)


func _physics_process_directional_movement(delta):
	var trackpad_vector = Vector2(-get_joystick_axis(1), get_joystick_axis(0))
	var joystick_vector = Vector2(-get_joystick_axis(5), get_joystick_axis(4))

	if trackpad_vector.length() < CONTROLLER_DEADZONE:
		trackpad_vector = Vector2(0,0)
	else:
		trackpad_vector = trackpad_vector.normalized() * ((trackpad_vector.length() - CONTROLLER_DEADZONE) / (1 - CONTROLLER_DEADZONE))

	if joystick_vector.length() < CONTROLLER_DEADZONE:
		joystick_vector = Vector2(0,0)
	else:
		joystick_vector = joystick_vector.normalized() * ((joystick_vector.length() - CONTROLLER_DEADZONE) / (1 - CONTROLLER_DEADZONE))

	var forward_direction = get_parent().get_node("Player_Camera").global_transform.basis.z.normalized()
	var right_direction = get_parent().get_node("Player_Camera").global_transform.basis.x.normalized()

	# Because the trackpad and the joystick will both move the player, we can add them together and normalize
	# the result, giving the combined movement direction
	var movement_vector = (trackpad_vector + joystick_vector).normalized()

	var movement_forward = forward_direction * movement_vector.x * delta * MOVEMENT_SPEED
	var movement_right = right_direction * movement_vector.y * delta * MOVEMENT_SPEED

	movement_forward.y = 0
	movement_right.y = 0

	if (movement_right.length() > 0 or movement_forward.length() > 0):
		get_parent().global_translate(movement_right + movement_forward)
		directional_movement = true
	else:
		directional_movement = false


func button_pressed(button_index):
	if button_index == 15:
		_on_button_pressed_trigger()

	if button_index == 2:
		_on_button_pressed_grab()

	if button_index == 1:
		_on_button_pressed_menu()


func _on_button_pressed_trigger():
	if held_object == null:
		if teleport_mesh.visible == false:
			teleport_button_down = true
			teleport_mesh.visible = true
			teleport_raycast.visible = true
	else:
		if held_object is VR_Interactable_Rigidbody:
			held_object.interact()


func _on_button_pressed_grab():
	if teleport_button_down == true:
		return

	if held_object == null:
		_pickup_rigidbody()
	else:
		_throw_rigidbody()

	hand_pickup_drop_sound.play()


func _pickup_rigidbody():
	var rigid_body = null

	if grab_mode == "AREA":
		var bodies = grab_area.get_overlapping_bodies()
		if len(bodies) > 0:
			for body in bodies:
				if body is RigidBody:
					if !("NO_PICKUP" in body):
						rigid_body = body
						break

	elif grab_mode == "RAYCAST":
		grab_raycast.force_raycast_update()
		if (grab_raycast.is_colliding()):
			var body = grab_raycast.get_collider()
			if body is RigidBody:
				if !("NO_PICKUP" in body):
					rigid_body = body


	if rigid_body != null:

		held_object = rigid_body

		held_object_data["mode"] = held_object.mode
		held_object_data["layer"] = held_object.collision_layer
		held_object_data["mask"] = held_object.collision_mask

		held_object.mode = RigidBody.MODE_STATIC
		held_object.collision_layer = 0
		held_object.collision_mask = 0

		hand_mesh.visible = false
		grab_raycast.visible = false

		if held_object is VR_Interactable_Rigidbody:
			held_object.controller = self
			held_object.picked_up()


func _throw_rigidbody():
	if held_object == null:
		return

	held_object.mode = held_object_data["mode"]
	held_object.collision_layer = held_object_data["layer"]
	held_object.collision_mask = held_object_data["mask"]

	held_object.apply_impulse(Vector3(0, 0, 0), controller_velocity)

	if held_object is VR_Interactable_Rigidbody:
		held_object.dropped()
		held_object.controller = null

	held_object = null
	hand_mesh.visible = true

	if grab_mode == "RAYCAST":
		grab_raycast.visible = true


func _on_button_pressed_menu():
	if grab_mode == "AREA":
		grab_mode = "RAYCAST"
		if held_object == null:
			grab_raycast.visible = true

	elif grab_mode == "RAYCAST":
		grab_mode = "AREA"
		grab_raycast.visible = false


func button_released(button_index):
	if button_index == 15:
		_on_button_released_trigger()


func _on_button_released_trigger():
	if teleport_button_down == true:

		if teleport_pos != null and teleport_mesh.visible == true:
			var camera_offset = get_parent().get_node("Player_Camera").global_transform.origin - get_parent().global_transform.origin
			camera_offset.y = 0

			get_parent().global_transform.origin = teleport_pos - camera_offset

		teleport_button_down = false
		teleport_mesh.visible = false
		teleport_raycast.visible = false
		teleport_pos = null


func sleep_area_entered(body):
	if "can_sleep" in body:
		body.can_sleep = false
		body.sleeping = false


func sleep_area_exited(body):
	if "can_sleep" in body:
		# Allow the CollisionBody to sleep by setting the "can_sleep" variable to true
		body.can_sleep = true
