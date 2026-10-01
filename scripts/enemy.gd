extends CharacterBody2D

signal died(enemy: Node2D)

@export var speed: float = 90.0
@export var max_health: int = 3
@export var contact_damage: int = 10
@export var experience_reward: int = 1

var target: Node2D
var health: int

@onready var body: Polygon2D = $Body


func _ready() -> void:
	health = max_health


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(target):
		velocity = Vector2.ZERO
		return

	velocity = global_position.direction_to(target.global_position) * speed
	move_and_slide()

	for collision_index in get_slide_collision_count():
		var collision := get_slide_collision(collision_index)
		var collider := collision.get_collider()
		if collider != null and collider.has_method("take_damage"):
			collider.take_damage(contact_damage)


func take_damage(amount: int) -> void:
	if amount <= 0 or health <= 0:
		return

	health = maxi(health - amount, 0)
	if health <= 0:
		_die()


func _die() -> void:
	_spawn_defeat_effect()
	died.emit(self)
	queue_free()


func _spawn_defeat_effect() -> void:
	var effect := Polygon2D.new()
	effect.polygon = body.polygon
	effect.color = body.color
	effect.z_index = z_index + 1
	get_parent().add_child(effect)
	effect.global_position = global_position
	effect.global_rotation = global_rotation

	var tween := effect.create_tween()
	tween.set_parallel(true)
	tween.tween_property(effect, "scale", Vector2(1.8, 1.8), 0.18)
	tween.tween_property(effect, "modulate", Color(1.0, 0.35, 0.25, 0.0), 0.18)
	tween.chain().tween_callback(effect.queue_free)
