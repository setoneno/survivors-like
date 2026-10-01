extends CharacterBody2D

signal health_changed(current_health: int, maximum_health: int)
signal level_changed(current_level: int)
signal experience_changed(current_experience: int, required_experience: int)
signal shot
signal died

@export var speed: float = 260.0
@export var attack_interval: float = 0.8
@export var attack_damage: int = 1
@export var max_health: int = 100
@export var invincibility_duration: float = 1.0

const HALF_SIZE := Vector2(16.0, 16.0)
const BULLET_SCENE: PackedScene = preload("res://scenes/bullet.tscn")
const MIN_ATTACK_INTERVAL: float = 0.1

var attack_timer: float = 0.0
var health: int
var invincibility_timer: float = 0.0
var is_dead: bool = false
var is_game_finished: bool = false
var level: int = 1
var experience: int = 0
var hit_flash_tween: Tween


func _ready() -> void:
	health = max_health


func _physics_process(delta: float) -> void:
	if is_dead or is_game_finished:
		velocity = Vector2.ZERO
		return

	invincibility_timer = maxf(invincibility_timer - delta, 0.0)

	velocity = _read_movement_direction() * speed
	move_and_slide()
	_keep_inside_viewport()

	_process_attack(delta)


func take_damage(amount: int) -> void:
	if is_dead or is_game_finished or invincibility_timer > 0.0 or amount <= 0:
		return

	health = maxi(health - amount, 0)
	health_changed.emit(health, max_health)
	_play_hit_flash()

	if health <= 0:
		_die()
	else:
		invincibility_timer = invincibility_duration


func gain_experience(amount: int) -> void:
	if is_dead or is_game_finished or amount <= 0:
		return

	experience += amount

	while experience >= get_required_experience():
		experience -= get_required_experience()
		level += 1
		level_changed.emit(level)
		print("LEVEL UP! Level %d" % level)

	experience_changed.emit(experience, get_required_experience())


func get_required_experience() -> int:
	return 5 + ((level - 1) * 2)


func upgrade_attack_damage() -> void:
	attack_damage += 1


func upgrade_attack_speed() -> void:
	attack_interval = maxf(attack_interval * 0.9, MIN_ATTACK_INTERVAL)
	attack_timer = minf(attack_timer, attack_interval)


func upgrade_movement_speed() -> void:
	speed *= 1.1


func finish_game() -> void:
	is_game_finished = true
	velocity = Vector2.ZERO
	set_physics_process(false)


func _play_hit_flash() -> void:
	if hit_flash_tween != null and hit_flash_tween.is_valid():
		hit_flash_tween.kill()

	modulate = Color(1.0, 0.3, 0.3, 1.0)
	hit_flash_tween = create_tween()
	hit_flash_tween.tween_property(self, "modulate", Color.WHITE, 0.2)


func _die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	died.emit()


func _read_movement_direction() -> Vector2:
	var direction := Vector2.ZERO

	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1.0

	return direction.normalized()


func _keep_inside_viewport() -> void:
	var viewport_size := get_viewport_rect().size

	position.x = clampf(
		position.x,
		HALF_SIZE.x,
		viewport_size.x - HALF_SIZE.x
	)

	position.y = clampf(
		position.y,
		HALF_SIZE.y,
		viewport_size.y - HALF_SIZE.y
	)


func _process_attack(delta: float) -> void:
	attack_timer -= delta

	if attack_timer > 0.0:
		return

	var target := _find_nearest_enemy()

	if target == null:
		return

	_shoot(target)

	attack_timer = attack_interval


func _find_nearest_enemy() -> Node2D:
	var enemies := get_tree().get_nodes_in_group("enemies")

	var nearest_enemy: Node2D = null
	var nearest_distance := INF

	for enemy in enemies:
		if not enemy is Node2D:
			continue

		var distance := global_position.distance_squared_to(
			enemy.global_position
		)

		if distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = enemy

	return nearest_enemy


func _shoot(target: Node2D) -> void:
	var bullet := BULLET_SCENE.instantiate()

	bullet.global_position = global_position
	bullet.direction = global_position.direction_to(target.global_position)
	bullet.damage = attack_damage

	get_parent().add_child(bullet)
	shot.emit()
