extends Node2D

@onready var pause_menu: PackedScene = preload("res://ui/pause_menu.tscn")
var game_ui: Node

func _ready() -> void:
	GameManager.on_game_over.connect(trigger_game_over)
	game_ui = get_node("System/GameUI")

func _input(event):
	if event.is_action_released("ui_cancel") and GameManager.is_game_paused == false:
		var pause = pause_menu.instantiate()
		add_child(pause)
		
func trigger_game_over():
	game_ui.queue_free()
	var game_over_ui = preload("res://ui/game_over_ui.tscn")
	var game_over = game_over_ui.instantiate()
	
	game_over.time_survived = GameManager.time_elapsed_string
	game_over.meat_collected = str(GameManager.collected_meat)
	game_over.enemies_slain = str(GameManager.enemies_slain)
	add_child(game_over)
