extends Node2D
#End credits


func _input(event):
	if Input.is_anything_pressed():
		%UI_Transition.play_backwards("Enter")
		await %UI_Transition.animation_finished
		get_tree().change_scene_to_file("res://assets/scenes/Main Menu.tscn")
