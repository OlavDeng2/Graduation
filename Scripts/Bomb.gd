extends "res://addons/godot-xr-tools/objects/Object_pickable.gd"

var bomb_mesh

const FUSE_TIME = 4
var fuse_timer = 0

var explosion_area
const EXPLOSION_DAMAGE = 100
const EXPLOSION_TIME = 0.75
var explosion_timer = 0
var exploded = false

const COLLISION_FORCE = 8

var fuse_particles
var explosion_particles
var explosion_sound


func _ready():

	bomb_mesh = get_node("Bomb")
	explosion_area = get_node("Area")
	fuse_particles = get_node("Fuse_Particles")
	explosion_particles = get_node("Explosion_Particles")
	explosion_sound = get_node("AudioStreamPlayer3D")

	set_physics_process(false)


func _physics_process(delta):

	if fuse_timer < FUSE_TIME:

		fuse_timer += delta

		if fuse_timer >= FUSE_TIME:

			fuse_particles.emitting = false

			explosion_particles.one_shot = true
			explosion_particles.emitting = true

			bomb_mesh.visible = false

			collision_layer = 0
			collision_mask = 0
			mode = RigidBody.MODE_STATIC

			for body in explosion_area.get_overlapping_bodies():
				if body == self:
					pass
				else:
					if body.has_method("damage"):
						body.damage(EXPLOSION_DAMAGE)

					if body is RigidBody:
						var direction_vector = body.global_transform.origin - global_transform.origin
						var bomb_distance = direction_vector.length()
						var collision_force = (COLLISION_FORCE / bomb_distance) * body.mass
						body.apply_impulse(Vector3.ZERO, direction_vector.normalized() * collision_force)

			exploded = true
			explosion_sound.play()


	if exploded:

		explosion_timer += delta

		if explosion_timer >= EXPLOSION_TIME:

			explosion_area.monitoring = false

			if picked_up_by != null:
				picked_up_by.drop_object()

			queue_free()


func action():
	set_physics_process(true)

	fuse_particles.emitting = true
