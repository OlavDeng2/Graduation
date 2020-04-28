extends VR_Interactable_Rigidbody

var player_controller
var start_transform
var current_movement_mode_label
var controls_label

func _ready():
	start_transform = global_transform
	#player_controller = get_node("Player")
	player_controller = get_tree().get_root().find_node("ARVROrigin", true, false)
	current_movement_mode_label = get_tree().get_root().find_node("Label_Movement_Mode", true, false)
	controls_label = get_tree().get_root().find_node("Label_Controls", true, false)

func interact():
	player_controller._change_movement_mode(player_controller.movement_mode)
	#change the listed movement mode in the GUI screen
	current_movement_mode_label.text = player_controller.movement_mode
	
	if player_controller.movement_mode == "Smooth" or player_controller.movement_mode == "Teleport":
		controls_label.text = "Move with the joysticks \n\nGrab and release objects by pressing the grip button\n\nWhile holding a object, press the trigger to interact\n\nCurrent Movement Mode:"
	elif player_controller.movement_mode == "Armswinger":
		controls_label.text = "Press 'b' button to use armswinger\n on the controller you want to move with\n(you can use both controllers) \n\nGrab and release objects by pressing the grip button\n\nWhile holding a object, press the trigger to interact\n\nCurrent Movement Mode:"
