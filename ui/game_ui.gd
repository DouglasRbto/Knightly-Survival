extends CanvasLayer

@onready var time_label: Label = %TimerLabel
@onready var meat_label: Label = %MeatLabel
@onready var experience_bar: TextureProgressBar = %Experience
@onready var experience_label: Label = %ExperienceLabel

func _process(_delta) -> void:
	time_label.text = GameManager.time_elapsed_string
	meat_label.text = str(GameManager.collected_meat)
	if GameManager.player:
		experience_label.text = "Level: %s" % [GameManager.player.level]
		experience_bar.min_value = GameManager.player.base_experience
		experience_bar.max_value = GameManager.player.experience_to_next_level
		experience_bar.value = GameManager.player.experience
