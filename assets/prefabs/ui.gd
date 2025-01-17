extends Control

@onready var coinsLabel = $Coins

func _physics_process(delta):
	coinsLabel.text = str(GlobalvALS.coinsG)
	
