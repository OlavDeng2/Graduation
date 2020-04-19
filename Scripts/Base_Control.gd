extends Control

var sphere_count_label

func _ready():
	sphere_count_label = get_node("Label_Sphere_Count")

	get_tree().root.get_node("Game").sphere_ui = self


func update_sphere_count(sphere_count):
	if sphere_count > 0:
		sphere_count_label.text = str(sphere_count) + " Spheres remaining"
	else:
		sphere_count_label.text = "No spheres remaining! Good job!"


func update_current_dominant_hand(current_dominant_hand):
	if current_dominant_hand == 2:
		#right hand is dominant
		pass
	elif current_dominant_hand == 1:
		#left hand is dominant
		pass
