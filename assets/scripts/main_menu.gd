extends Node2D

func _input(event):
	if Input.is_anything_pressed():
		$AnimationPlayer.play_backwards("enter")
		await $AnimationPlayer.animation_finished
		get_tree().change_scene_to_file("res://assets/scenes/Levels/Level_01.tscn")
