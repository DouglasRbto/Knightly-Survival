class_name Player
extends CharacterBody2D

@export_category("movement")
@export var speed: float = 2
@export_category("sword")
@export var sword_damage: int = 1
@export_category("ritual")
@export var ritual_interval: float = 40
@export var ritual_cooldown: float = 0
@export var ritual_scene: PackedScene
@export_category("life")
@export var health: int = 100
@export var max_health: int = 100
@export var death_prefab: PackedScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var health_progress_bar: TextureProgressBar = $HealthProgressBar
@onready var spell_progress_bar: TextureProgressBar = $SpellProgressBar
@onready var damage_digit_marker = $DamageDigitMaker
@onready var hit_sound = $HitSound
@onready var pickup_sound = $PickupSound
@onready var ritual_ready_indication = $RitualReady
@onready var level_up_sprite = $LevelUp
@onready var level_up_sound = $LevelUpSound

var damage_digit_prefab: PackedScene
var pickup_text_prefab: PackedScene
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var input_vector: Vector2 = Vector2.ZERO
var level: int = 1
var base_experience: int = 0
var experience_to_next_level: int = 20
var experience: int = 0

signal meat_collected()

func _ready() -> void:
	GameManager.player = self
	damage_digit_prefab = preload("res://misc/damage_digit.tscn")
	pickup_text_prefab = preload("res://misc/pickup_text.tscn")
	meat_collected.connect(func(): GameManager.collected_meat += 1)
	
func _process(delta: float) -> void:
	GameManager.player_position = position
	update_hitbox_detection(delta)
	read_input()
	if !is_attacking:
		rotate_sprite()
	play_run_idle_animation()
	update_attack_cooldown(delta)
	if Input.is_action_pressed("attack"):
		attack()
	if Input.is_action_pressed("cast_spell"):
		cast_spell()
	
	if ritual_cooldown >= ritual_interval and ritual_ready_indication.visible == false:
		ritual_ready_indication.visible = true
	
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health
	spell_progress_bar.max_value = ritual_interval
	spell_progress_bar.value = ritual_cooldown

func _physics_process(delta: float) -> void:
	var target_velocity = input_vector * speed * 10000 * delta
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.1)
	move_and_slide()
	ritual_cooldown += delta
	
func read_input() -> void:
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var _deadzone = 0.15
	if abs(input_vector.x) < 0.15:
		input_vector.x = 0.0
	if abs(input_vector.y) < 0.15:
		input_vector.y = 0.0
		
	was_running = is_running
	is_running = !input_vector.is_zero_approx()

func play_run_idle_animation() -> void:
	if !is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")

func rotate_sprite() -> void:
	if get_global_mouse_position().x < global_position.x:
		sprite.flip_h = true
	elif get_global_mouse_position().x > global_position.x:
		sprite.flip_h = false

func update_attack_cooldown(delta: float) -> void:
	if is_attacking:
		attack_cooldown -= delta
		is_running = false
		if attack_cooldown <= 0.0:
			is_attacking = false
			rotate_sprite()
			animation_player.play("idle")

func cast_spell() -> void:
	if ritual_cooldown < ritual_interval: return
	ritual_cooldown = 0
	ritual_ready_indication.visible = false
	
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = sword_damage * 2
	add_sibling(ritual)

func attack() -> void:
	if is_attacking:
		return
	var attack_direction: Vector2 = get_global_mouse_position() - global_position
	var attack_animation = randi_range(1,2)
	if abs(attack_direction.x) > abs(attack_direction.y):
		animation_player.play("attack_side_" + str(attack_animation))
	elif abs(attack_direction.x) < abs(attack_direction.y):
		if attack_direction.y < 0:
			animation_player.play("attack_up_" + str(attack_animation))
		elif attack_direction.y > 0:
			animation_player.play("attack_down_" + str(attack_animation))
	attack_cooldown = 0.6
	is_attacking = true
	
func deal_damage_to_enemies() -> void:
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var direction_to_enemy: Vector2 = (body.global_position - global_position).normalized()
			var attack_direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product > 0.3:
				body.take_damage(sword_damage, self)
				
func update_hitbox_detection(delta: float) -> void:
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0: return

	hitbox_cooldown = 0.5
	
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			take_damage(body.damage + int((GameManager.time_elapsed / 60)), body)

func take_damage(amount: int, source: Enemy) -> void:
	if health <= 0: return
	var knockback_direction = source.global_position.direction_to(global_position)
	var knockback = global_position + knockback_direction * 20
	create_tween().tween_property(self,"position", knockback,0.2).set_ease(Tween.EASE_OUT)
	
	hit_sound.play()
	health -= amount
	sprite.modulate = Color.RED
	create_tween().tween_property(sprite,"modulate",Color.WHITE,0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	
	var damage_digit = damage_digit_prefab.instantiate()
	damage_digit.value = str(amount)
	if damage_digit_marker:
		damage_digit.position = damage_digit_marker.position
	else: 
		damage_digit.position = position
	add_child(damage_digit)
	
	if health <= 0:
		die()
		
func die() -> void:
	if death_prefab:
		var death_object = death_prefab.instantiate()
		add_sibling(death_object)
		death_object.position = position
		death_object.scale = Vector2(1.5,1.5)
	queue_free()
	
	GameManager.game_over()

func heal(amount: int) -> int:
	var pickup_text = pickup_text_prefab.instantiate()
	
	if amount == 20: pickup_text.value = "Meat Collected!"
	elif amount == 100: pickup_text.value = "Super Meat Collected!!!"
	
	if damage_digit_marker:
		pickup_text.position = damage_digit_marker.position
	else: 
		pickup_text.position = position
	add_child(pickup_text)
	
	health += amount
	if health > max_health:
		health = max_health
	return health

func upgrade_damage() -> void:
	sword_damage = level

func update_experience(amount: int) -> void:
	experience += amount
	
	if experience >= experience_to_next_level:
		level_up()

func level_up() -> void:
	var pickup_text = pickup_text_prefab.instantiate()
	pickup_text.value = "Level UP!"
	if damage_digit_marker:
		pickup_text.position = damage_digit_marker.position
	else: 
		pickup_text.position = position
	add_child(pickup_text)
	level_up_sprite.visible = true
	level_up_sprite.play("default")
	level_up_sound.play()
	
	health = 100
	level += 1
	upgrade_damage()
	var current_experience = experience_to_next_level
	experience_to_next_level = int(pow((level), 2) * 20)
	base_experience = current_experience
	await level_up_sprite.animation_finished
	level_up_sprite.visible = false
