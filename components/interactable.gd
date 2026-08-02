extends Area2D
class_name Interactable

signal interacted

@export var prompt_message: String = "Interact"
@export var interaction_radius: float = 30.0

var _player_in_range: bool = false

func _ready():
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player") or body.name == "Player":
		_player_in_range = true

func _on_body_exited(body: Node2D):
	if body.is_in_group("player") or body.name == "Player":
		_player_in_range = false

func trigger_interaction():
	if _player_in_range:
		emit_signal("interacted")
