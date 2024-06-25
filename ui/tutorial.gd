extends ColorRect

func _input(event) -> void:
	if event.is_action_pressed("attack") or event.is_action_pressed("cast_spell") or event.is_action_pressed("ui_accept"):
		GameManager.reset()
		get_tree().change_scene_to_file("res://main.tscn")
