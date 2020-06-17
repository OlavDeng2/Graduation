extends Node

#The different screens
export (NodePath) var main_menu_screen = null
export (NodePath) var settings_screen = null
export (NodePath) var credits_screen = null


var current_screen = null

#variables to choose what goes on dominant hand and what goes on secondary hand
var player = null

func _ready():
	player = PlayerSettings.player
	
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
	current_screen = new_screen#get_node(new_screen)
	current_screen.visible = true


#Function for switching movement method
func _switch_movement_method(var new_movement_method):
	pass


#Armswinger settings


#Teleport settings


#Smooth Locomotion settings


func _main_menu_credits_button():
	_switch_screen(credits_screen)


func _credits_back_button():
	_switch_screen(main_menu_screen)


func _main_menu_settings_button():
	_switch_screen(settings_screen)



func _settings_change_dominant_hand_button():
	player.toggle_dominant_hand()
	#todo: change the current text on the label
