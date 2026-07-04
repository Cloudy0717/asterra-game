extends StaticBody2D

@onready var sprite = $Sprite2D

func _ready():
	sprite.texture = Sprites.characters["lina"]
	sprite.hframes = 3
	sprite.vframes = 4
	sprite.frame = 0 # Down, idle frame
