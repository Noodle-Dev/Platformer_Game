extends Node2D


func _on_area_2d_body_entered(body : CharacterBody2D):
	if body.is_in_group("Player"):
		GlobalvALS.lives = 0
		print("Player dead instantly")
