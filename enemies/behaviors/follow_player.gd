extends Node

@export var speed: float = 1
@onready var input_vector: Vector2

var enemy: Enemy
var sprite: AnimatedSprite2D

func _ready() -> void:
	enemy = get_parent()
	sprite = enemy.get_node("AnimatedSprite2D")

func _physics_process(_delta: float) -> void:
	if GameManager.is_game_over: return
	var player_position = GameManager.player_position
	input_vector = (player_position - enemy.position).normalized()
	enemy.velocity = input_vector * speed * 100
	enemy.move_and_slide()
	rotate_sprite()

func rotate_sprite() -> void:
	if input_vector.x < 0:
		sprite.flip_h = true
	elif input_vector.x > 0:
		sprite.flip_h = false
