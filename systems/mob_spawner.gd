class_name MobSpawner
extends Node2D

@export var creatures: Array[PackedScene]
@export var spawn_chances: Array[float]
@export var mobs_per_minute: float = 50

var spawn_chances_default_values: Array[float]
var cooldown: float = 0
@onready var path_follow_2d: PathFollow2D = %PathFollow2D

func _ready() -> void:
	spawn_chances_default_values = spawn_chances

func _process(delta:float) -> void:
	if GameManager.is_game_over: return
	
	cooldown -= delta
	if cooldown > 0: return
		
	var interval = 60 / mobs_per_minute
	cooldown = interval
	
	var point = get_point()
	var world_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = point
	
	var result: Array = world_state.intersect_point(parameters)
	
	if not result.is_empty(): return
	
	var index = 0
	var spawn_chance = randf()
	
	if spawn_chance <= spawn_chances[0]:
		index = 0
	elif spawn_chance <= spawn_chances[1]:
		index = 1
	elif spawn_chance <= spawn_chances[2]:
		index = 2
	elif spawn_chance <= spawn_chances[2]:
		index = 3
			
	var creature_scene = creatures[index]
	var creature = creature_scene.instantiate()
	creature.position = point
	add_sibling(creature)

func get_point() -> Vector2:
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.global_position

func _on_villager_spawn_body_entered(body):
	if body == GameManager.player:
		spawn_chances[0] = 0.2
		spawn_chances[1] = 0.8
		spawn_chances[2] = 0

func _on_villager_spawn_body_exited(body):
	if body == GameManager.player:
		spawn_chances = spawn_chances_default_values
		
func _on_goblin_spawn_body_entered(body):
	if body == GameManager.player:
		spawn_chances[0] = 0.05
		spawn_chances[1] = 0
		spawn_chances[2] = 0.8
		spawn_chances[3] = 0.15

func _on_goblin_spawn_body_exited(body):
	if body == GameManager.player:
		spawn_chances = spawn_chances_default_values
