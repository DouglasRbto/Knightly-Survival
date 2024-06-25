extends CanvasLayer

@onready var confirmation_sound = $ConfirmSound
@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	get_tree().paused = true
	GameManager.is_game_paused = true
	
func _input(event) -> void:
	if event.is_action_released("ui_cancel") and GameManager.is_game_paused:
		_on_continue_button_button_up()
	
func _on_continue_button_button_up():
	confirmation_sound.play()
	animation_player.play_backwards("default")
	await animation_player.animation_finished
	get_tree().paused = false
	GameManager.is_game_paused = false
	queue_free()
	
func _on_restart_button_button_up() -> void:
	confirmation_sound.play()
	animation_player.play_backwards("default")
	restart_game()

func _on_settings_button_button_up():
	confirmation_sound.play()
	animation_player.play("Settings")
	
func _on_close_settings_button_button_up():
	confirmation_sound.play()
	animation_player.play_backwards("Settings")

func _on_exit_button_button_up():
	confirmation_sound.play()
	animation_player.play_backwards("default")
	await animation_player.animation_finished
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
	GameManager.reset()

func restart_game() -> void:
	animation_player.play_backwards("default")
	await animation_player.animation_finished
	GameManager.reset()
	get_tree().paused = false
	get_tree().reload_current_scene()
