extends Node

#The different screens
export (NodePath) var main_menu_screen = null
export (NodePath) var settings_screen = null
export (NodePath) var credits_screen = null


#The different labels to change
export (NodePath) var movement_mode_text = null
export (NodePath) var dominant_hand_text = null
export (NodePath) var current_turning_method_text = null

#the node for the different labels
var movement_mode_text_node = null
var dominant_hand_text_node = null
var current_turning_method_text_node = null


var current_screen = null

#variables to choose what goes on dominant hand and what goes on secondary hand
var player = null

func _ready():
	player = PlayerSettings.player
	if(movement_mode_text):
		movement_mode_text_node = get_node(movement_mode_text)
	if(dominant_hand_text):
		dominant_hand_text_node = get_node(dominant_hand_text)
	if(current_turning_method_text):
		current_turning_method_text_node = get_node(current_turning_method_text)
	
	#set the current screen. by default will be main menu
	current_screen = get_node("Main_Menu")
	
	if(main_menu_screen):
		main_menu_screen = get_node(main_menu_screen)
	
	#By default, everything but the current screen should be set to invisible
	if(settings_screen):
		settings_screen = get_node(settings_screen)
		settings_screen.visible = false
		
	if(credits_screen):
		credits_screen = get_node(credits_screen)
		credits_screen.visible = false
	
	

#function for switching between sub menus(including going back)
func _switch_screen(var new_screen):
	current_screen.visible = false
	current_screen = new_screen
	current_screen.visible = true


#Function for switching movement method
func _settings_switch_movement_method():
	player.change_movement_mode()


func _main_menu_credits_button():
	_switch_screen(credits_screen)


func _credits_back_button():
	_switch_screen(main_menu_screen)


func _main_menu_settings_button():
	_switch_screen(settings_screen)



func _settings_change_dominant_hand_button():
	player.toggle_dominant_hand()
	#todo: change the current text on the label


func _settings_toggle_turning_mode():
	player.toggle_snapturn()
	#todo: change the current text on the label


func _settings_armswinger_follow_headset():
	player.toggle_follow_headset_armswinger()


func _settings_smooth_follow_headset():
	player.toggle_follow_headset_smooth_locomotion()
	pass # Replace with function body.


func _settings_armswinger_move_speed_value_changed(value):
	pass # Replace with function body.
