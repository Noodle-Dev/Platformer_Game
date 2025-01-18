extends Node2D

@export var NextLevel : PackedScene

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
	#	%UI_Transition.play_backwards("Enter")
	#	await %UI_Transition.animation_finished
		get_tree().change_scene_to_packed(NextLevel)
