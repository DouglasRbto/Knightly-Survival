extends Node

@onready var confirmation_sound = $ConfirmSound
@onready var credits = $Credits
@onready var animation_player = $AnimationPlayer
@onready var tutorial_scene = preload("res://ui/tutorial.tscn")

func _on_start_button_button_up():
	confirmation_sound.play()
	animation_player.play_backwards("Enter")
	await animation_player.animation_finished
	if GameManager.first_play:
		var tutorial = tutorial_scene.instantiate()
		add_child(tutorial)
	else: get_tree().change_scene_to_file("res://main.tscn")

func _on_settings_button_button_up():
	confirmation_sound.play()
	animation_player.play("Settings")
	
func _on_credits_button_button_up():
	confirmation_sound.play()
	animation_player.play("Credits")
	
func _on_exit_button_button_up():
	confirmation_sound.play()
	animation_player.play_backwards("Enter")
	await animation_player.animation_finished
	get_tree().quit()

func _on_close_credits_button_button_up():
	confirmation_sound.play()
	animation_player.play_backwards("Credits")

func _on_close_settings_button_button_up():
	confirmation_sound.play()
	animation_player.play_backwards("Settings")
