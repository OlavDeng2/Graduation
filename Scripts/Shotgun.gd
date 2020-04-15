extends VR_Interactable_Rigidbody

var flash_mesh
const FLASH_TIME = 0.25
var flash_timer = 0

var laser_sight_mesh
var shotgun_fire_sound

var raycasts
const BULLET_DAMAGE = 30
const COLLISION_FORCE = 4


func _ready():
	flash_mesh = get_node("Shotgun_Flash")
	flash_mesh.visible = false

	laser_sight_mesh = get_node("LaserSight")
	laser_sight_mesh.visible = false

	raycasts = get_node("Raycasts")
	shotgun_fire_sound = get_node("AudioStreamPlayer3D")


func _physics_process(delta):
	if flash_timer > 0:
		flash_timer -= delta
		if flash_timer <= 0:
			flash_mesh.visible = false


func interact():
	if flash_timer <= 0:

		flash_timer = FLASH_TIME
		flash_mesh.visible = true

		for raycast in raycasts.get_children():

			if not raycast is RayCast:
				continue

			raycast.rotation_degrees = Vector3(90 + rand_range(10, -10), 0, rand_range(10, -10))

			raycast.force_raycast_update()
			if raycast.is_colliding():

				var body = raycast.get_collider()
				var direction_vector = raycasts.global_transform.basis.z.normalized()
				var raycast_distance = raycasts.global_transform.origin.distance_to(raycast.get_collision_point())

				if body.has_method("damage"):
					body.damage(BULLET_DAMAGE)

				if body is RigidBody:
					var collision_force = (COLLISION_FORCE / raycast_distance) * body.mass
					body.apply_impulse((raycast.global_transform.origin - body.global_transform.origin).normalized(), direction_vector * collision_force)

		shotgun_fire_sound.play()

		if controller != null:
			controller.rumble = 0.25


func picked_up():
	laser_sight_mesh.visible = true


func dropped():
	laser_sight_mesh.visible = false
