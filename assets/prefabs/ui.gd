extends Control

@onready var coinsLabel = $Coins

@onready var lives = [
	$Live1,
	$Live2,
	$Live3
]

func _physics_process(delta):
	coinsLabel.text = str(GlobalvALS.coinsG)
	update_lives()
func update_lives():
	for i in range(lives.size()):
		lives[i].visible = i < GlobalvALS.lives
