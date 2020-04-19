extends VR_Interactable_Rigidbody

var player_controller
var start_transform
var current_movement_mode_label

func _ready():
	start_transform = global_transform
	#player_controller = get_node("Player")
	player_controller = get_tree().get_root().find_node("ARVROrigin", true, false)
	current_movement_mode_label = get_node("Label_Change_Movement_Mode")

func interact():
	player_controller._change_movement_mode(player_controller.movement_mode)
	#change the listed movement mode in the GUI screen
