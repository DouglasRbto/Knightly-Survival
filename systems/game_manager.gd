extends Node

signal on_game_over

var player: Player
var player_position: Vector2
var collected_meat: int
var is_game_over: bool = false
var is_game_paused: bool = false
var time_elapsed: float = 0
var time_elapsed_string: String
var enemies_slain: int = 0
var first_play: bool = true

func _process(delta) -> void:
	time_elapsed += delta
	var time_elapsed_seconds: int = floori(time_elapsed)
	var seconds: int = time_elapsed_seconds % 60
	var minutes: int = time_elapsed_seconds / 60
	time_elapsed_string = "%02d:%02d" % [minutes, seconds]

func game_over() -> void:
	if is_game_over: return
	is_game_over = true
	emit_signal("on_game_over")

func reset() -> void:
	player = null
	player_position = Vector2.ZERO
	collected_meat = 0
	time_elapsed = 0
	time_elapsed_string = ""
	enemies_slain = 0
	is_game_over = false
	is_game_paused = false
	first_play = false
	for connection in on_game_over.get_connections():
		on_game_over.disconnect(connection.callable)
