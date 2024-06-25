extends Node

var mob_spawner: MobSpawner
var initial_spawn_rate: int = 40
var spawn_rate_per_minute: int = 100
var wave_duration: float = 15
var time: float = 0
var break_intensity: float = 0.5

func _ready() -> void:
	mob_spawner = get_node("../MobSpawner")

func _process(delta) -> void:
	if GameManager.is_game_over: return
	
	time *= delta
	var spawn_rate = initial_spawn_rate + spawn_rate_per_minute * (time /60)
	var sin_wave = sin((time * TAU) / wave_duration)
	var wave_factor = remap(sin_wave,-1, 1, break_intensity, 1)
	
	mob_spawner.mobs_per_minute = int(spawn_rate * wave_factor)
