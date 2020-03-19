extends MeshInstance

# Makes a new material and makes the viewport (called GUI) texture
# the texture for the MeshInstance.

func _ready():
	
	# Get the viewport and wait two frames
	var viewport = get_node("GUI")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	# Get the texture
	var gui_img = viewport.get_texture()
	
	# Make a new material and set the viewport texture as the texture, then set
	# the material for this MeshInstance to the newly created material.
	var material = SpatialMaterial.new()
	material.flags_unshaded = true
	material.albedo_texture = gui_img
	set_surface_material(0, material)
