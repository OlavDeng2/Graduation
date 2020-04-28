extends VR_Interactable_Rigidbody

var start_transform

var reset_timer = 0
const RESET_TIME = 10
const RESET_MIN_DISTANCE = 1


func _ready():
	start_transform = global_transform


func _physics_process(delta):
	if start_transform.origin.distance_to(global_transform.origin) >= RESET_MIN_DISTANCE:
		reset_timer += delta
		if reset_timer >= RESET_TIME:
			global_transform = start_transform
			reset_timer = 0


func interact():
	# (Ignore the unused variable warning)
	# warning-ignore:return_value_discarded
	#get_tree().change_scene("res://Game.tscn")
	get_tree().reload_current_scene()


func dropped():
	global_transform = start_transform
	reset_timer = 0
