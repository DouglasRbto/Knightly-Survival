extends Node2D

@export var regeneration_amount: int = 10

func _ready() -> void:
	$Area2D.body_entered.connect(on_body_entered)

func on_body_entered(body) -> void:
	if body == GameManager.player:
		var player: Player = body
		player.heal(regeneration_amount)
		player.meat_collected.emit()
		player.pickup_sound.play()
		queue_free()
