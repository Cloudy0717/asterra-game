extends StaticBody2D

@onready var sprite = $Sprite2D

func _ready():
	sprite.texture = Sprites.objects["bulletin_board"]
