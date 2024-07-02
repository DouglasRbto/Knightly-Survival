extends Node

var mob_spawner: MobSpawner
var initial_spawn_rate: int = 20
var spawn_rate_per_minute: int = 30
var wave_duration: float = 20
var time: float = 0.0
var break_intensity: float = 0.5

func _ready() -> void:
	mob_spawner = get_node("../MobSpawner")

func _process(delta) -> void:
	if GameManager.is_game_over: return
	
	time += delta
	var spawn_rate = initial_spawn_rate + spawn_rate_per_minute * (time / 60)
	var sin_wave = sin((time * TAU) / wave_duration)
	var wave_factor = remap(sin_wave,-1.0, 1.0, break_intensity, 1)
	spawn_rate *= wave_factor
	
	mob_spawner.mobs_per_minute = spawn_rate
