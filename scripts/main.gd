extends Node2D

const ENEMY_SCENE: PackedScene = preload("res://scenes/enemy.tscn")
const SPAWN_MARGIN: float = 30.0
const GAME_DURATION_SECONDS: float = 60.0

@onready var player: Node2D = $Player
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer
@onready var sound_effects: SoundEffects = $SoundEffects
@onready var time_label: Label = $TimeLabel
@onready var health_label: Label = $HealthLabel
@onready var health_bar: ProgressBar = $HealthBar
@onready var level_label: Label = $LevelLabel
@onready var experience_label: Label = $ExperienceLabel
@onready var game_over_label: Label = $GameOverLabel
@onready var game_clear_label: Label = $GameClearLabel
@onready var end_overlay: ColorRect = $EndOverlay
@onready var upgrade_backdrop: ColorRect = $UpgradeBackdrop
@onready var upgrade_panel: Panel = $UpgradePanel
@onready var attack_damage_button: Button = $UpgradePanel/AttackDamageButton
@onready var attack_speed_button: Button = $UpgradePanel/AttackSpeedButton
@onready var movement_speed_button: Button = $UpgradePanel/MovementSpeedButton

var is_game_over: bool = false
var is_game_clear: bool = false
var is_upgrade_selection_active: bool = false
var pending_upgrade_choices: int = 0
var remaining_time: float = GAME_DURATION_SECONDS
var last_player_health: int = 0


func _ready() -> void:
	last_player_health = player.health
	enemy_spawn_timer.timeout.connect(_spawn_enemy)
	player.health_changed.connect(_on_player_health_changed)
	player.level_changed.connect(_on_player_level_changed)
	player.experience_changed.connect(_update_experience_label)
	player.died.connect(_on_player_died)
	player.shot.connect(_on_player_shot)
	attack_damage_button.pressed.connect(_on_attack_damage_button_pressed)
	attack_speed_button.pressed.connect(_on_attack_speed_button_pressed)
	movement_speed_button.pressed.connect(_on_movement_speed_button_pressed)
	_update_time_label()
	_update_health_label(player.health, player.max_health)
	_update_level_label(player.level)
	_update_experience_label(player.experience, player.get_required_experience())
	end_overlay.hide()
	game_over_label.hide()
	game_clear_label.hide()
	upgrade_backdrop.hide()
	upgrade_panel.hide()


func _process(delta: float) -> void:
	if _has_game_ended():
		return

	remaining_time = maxf(remaining_time - delta, 0.0)
	_update_time_label()

	if is_zero_approx(remaining_time):
		_on_game_clear()


func _exit_tree() -> void:
	if is_upgrade_selection_active:
		get_tree().paused = false


func _spawn_enemy() -> void:
	if _has_game_ended():
		return

	var enemy := ENEMY_SCENE.instantiate()

	enemy.target = player
	enemy.position = _get_random_spawn_position()
	enemy.died.connect(_on_enemy_died)

	add_child(enemy)


func _update_health_label(current_health: int, maximum_health: int) -> void:
	health_label.text = "HP: %d / %d" % [current_health, maximum_health]
	health_bar.max_value = maximum_health
	health_bar.value = current_health


func _on_player_health_changed(current_health: int, maximum_health: int) -> void:
	if current_health < last_player_health:
		sound_effects.play_player_hit()
	last_player_health = current_health
	_update_health_label(current_health, maximum_health)


func _update_time_label() -> void:
	var total_seconds := ceili(remaining_time)
	var minutes := floori(float(total_seconds) / 60.0)
	var seconds := total_seconds % 60
	time_label.text = "Time: %02d:%02d" % [minutes, seconds]

	if remaining_time <= 10.0:
		time_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.3))
	else:
		time_label.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0))


func _update_level_label(current_level: int) -> void:
	level_label.text = "Level: %d" % current_level


func _on_player_level_changed(current_level: int) -> void:
	_update_level_label(current_level)
	if _has_game_ended():
		return

	sound_effects.play_level_up()
	pending_upgrade_choices += 1

	if not is_upgrade_selection_active:
		_show_upgrade_selection()


func _update_experience_label(current_experience: int, required_experience: int) -> void:
	experience_label.text = "XP: %d / %d" % [current_experience, required_experience]


func _on_enemy_died(enemy: Node2D) -> void:
	if _has_game_ended() or player.is_dead:
		return

	sound_effects.play_enemy_defeated()
	player.gain_experience(enemy.experience_reward)


func _on_player_shot() -> void:
	if not _has_game_ended():
		sound_effects.play_shot()


func _show_upgrade_selection() -> void:
	if _has_game_ended() or pending_upgrade_choices <= 0:
		return

	is_upgrade_selection_active = true
	upgrade_backdrop.show()
	upgrade_panel.show()
	get_tree().paused = true


func _on_attack_damage_button_pressed() -> void:
	if not _can_select_upgrade():
		return

	player.upgrade_attack_damage()
	_complete_upgrade_selection()


func _on_attack_speed_button_pressed() -> void:
	if not _can_select_upgrade():
		return

	player.upgrade_attack_speed()
	_complete_upgrade_selection()


func _on_movement_speed_button_pressed() -> void:
	if not _can_select_upgrade():
		return

	player.upgrade_movement_speed()
	_complete_upgrade_selection()


func _can_select_upgrade() -> bool:
	return is_upgrade_selection_active and not _has_game_ended() and pending_upgrade_choices > 0


func _complete_upgrade_selection() -> void:
	pending_upgrade_choices = maxi(pending_upgrade_choices - 1, 0)

	if pending_upgrade_choices > 0:
		return

	is_upgrade_selection_active = false
	upgrade_backdrop.hide()
	upgrade_panel.hide()
	get_tree().paused = false


func _on_player_died() -> void:
	if is_game_clear:
		return

	is_game_over = true
	pending_upgrade_choices = 0
	is_upgrade_selection_active = false
	upgrade_backdrop.hide()
	upgrade_panel.hide()
	get_tree().paused = false
	enemy_spawn_timer.stop()
	end_overlay.show()
	game_over_label.show()
	sound_effects.play_game_over()

	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)


func _on_game_clear() -> void:
	if _has_game_ended() or player.is_dead:
		return

	is_game_clear = true
	remaining_time = 0.0
	pending_upgrade_choices = 0
	is_upgrade_selection_active = false
	upgrade_backdrop.hide()
	upgrade_panel.hide()
	get_tree().paused = false
	enemy_spawn_timer.stop()
	_update_time_label()
	end_overlay.show()
	game_clear_label.show()
	sound_effects.play_game_clear()
	player.finish_game()

	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)

	for bullet in get_tree().get_nodes_in_group("bullets"):
		bullet.set_physics_process(false)
		bullet.set_deferred("monitoring", false)


func _has_game_ended() -> bool:
	return is_game_over or is_game_clear


func _get_random_spawn_position() -> Vector2:
	var viewport_size := get_viewport_rect().size
	var side := randi_range(0, 3)

	match side:
		0:
			return Vector2(
				randf_range(0.0, viewport_size.x),
				-SPAWN_MARGIN
			)
		1:
			return Vector2(
				viewport_size.x + SPAWN_MARGIN,
				randf_range(0.0, viewport_size.y)
			)
		2:
			return Vector2(
				randf_range(0.0, viewport_size.x),
				viewport_size.y + SPAWN_MARGIN
			)
		_:
			return Vector2(
				-SPAWN_MARGIN,
				randf_range(0.0, viewport_size.y)
			)
