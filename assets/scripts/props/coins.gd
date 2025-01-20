extends Node2D

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		GlobalvALS.coinsG += 1
		$AudioStreamPlayer2D.play()
		$Sprite2D.visible = false
		$Area2D.visible = false
		await  $AudioStreamPlayer2D.finished
		queue_free()
