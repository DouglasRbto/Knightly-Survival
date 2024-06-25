extends CanvasLayer

@onready var time_label = %TimeLabel
@onready var meat_label = %MeatLabel
@onready var enemies_label = %EnemiesLabel
@onready var confirmation_sound = $ConfirmSound

var time_survived: String
var meat_collected: String
var enemies_slain: String

func _ready() -> void:
	time_label.text = time_survived
	meat_label.text = meat_collected
	enemies_label.text = enemies_slain

func _on_restart_button_button_up() -> void:
	confirmation_sound.play()
	await get_tree().create_timer(0.5).timeout
	restart_game()
	
func restart_game() -> void:
	GameManager.reset()
	get_tree().reload_current_scene()


func _on_exit_button_button_up():
	confirmation_sound.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
	GameManager.reset()
