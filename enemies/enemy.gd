class_name Enemy
extends Node2D

@export_category("Life")
@export var death_prefab: PackedScene
@export var health: int = 10
@export_category("Drops")
@export var drop_chance: float = 0.15
@export var drop_items: Array[PackedScene]
@export var drop_chances: Array[float]

@export var damage: int = 1
@export var experience: int = 10
@export var knockback_force: int = 40

@onready var damage_digit_marker = $DamageDigitMarker
@onready var hit_sound = $HitSound

var damage_digit_prefab: PackedScene

func _ready() -> void:
	damage_digit_prefab = preload("res://misc/damage_digit.tscn")
	if GameManager.time_elapsed >= 60:
		health += health * int((GameManager.time_elapsed / 60))

func take_damage(amount: int, source: Player) -> void:
	hit_sound.play()
	health -= amount
	
	modulate = Color.RED
	create_tween().tween_property(self,"modulate",Color.WHITE,0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	
	var damage_digit = damage_digit_prefab.instantiate()
	damage_digit.value = str(amount)
	if damage_digit_marker:
		damage_digit.position = damage_digit_marker.global_position
	else: 
		damage_digit.position = global_position
	add_sibling(damage_digit)
	
	var knockback_direction = source.global_position.direction_to(global_position)
	var knockback = global_position + knockback_direction * knockback_force
	
	if amount == source.sword_damage:
		await create_tween().tween_property(self,"position", knockback,0.2).set_ease(Tween.EASE_OUT).finished
	else:
		knockback = global_position + knockback_direction * 10
		await create_tween().tween_property(self,"position", knockback,0.2).set_ease(Tween.EASE_OUT).finished
	
	if health <= 0:
		die()
		
func die() -> void:
	if randf() <= drop_chance:
		drop_item()
		
	if death_prefab:
		var death_object = death_prefab.instantiate()
		add_sibling(death_object)
		death_object.position = position
			
	GameManager.enemies_slain += 1
	GameManager.player.update_experience(experience)
	queue_free()
	
func drop_item() -> void:
	var drop = get_random_drop_item().instantiate()
	add_sibling(drop)
	drop.position = position
	
func get_random_drop_item() -> PackedScene:
	if drop_items.size() == 1:
		return drop_items[0]
	
	var max_chance: float = 0
	
	for drop_chance in drop_chances:
		max_chance += drop_chance
	
	var random_value: float = randf() * max_chance
	var value: float = 0
	
	for i in drop_items.size():
		var item_to_drop = drop_items[i]
		var chance = drop_chances[i] if i < drop_chances.size() else 1
		if random_value <= chance + value:
			return item_to_drop
		value += chance
	return drop_items[0]
