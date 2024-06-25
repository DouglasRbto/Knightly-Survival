extends Node2D

@export var damage_amount: int
@onready var area2d: Area2D = $Area2D

func deal_damage() -> void:
	var bodies = area2d.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			body.take_damage(damage_amount, GameManager.player)

func _physics_process(_delta) -> void:
	position = GameManager.player.position - Vector2(0,16)
