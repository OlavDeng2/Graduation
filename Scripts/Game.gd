extends Spatial

var spheres_left = 10
var sphere_ui = null

func _ready():
	var VR = ARVRServer.find_interface("OpenVR")
	if VR and VR.initialize():
		get_viewport().arvr = true
		get_viewport().hdr = false

		OS.vsync_enabled = false
		Engine.target_fps = 120
		# Also, the physics FPS in the project settings is also 90 FPS. This makes the physics
		# run at the same frame rate as the display, which makes things look smoother in VR!

func remove_sphere():
	spheres_left -= 1

	if sphere_ui != null:
		sphere_ui.update_ui(spheres_left)
