extends Area2D
## A wireframe diamond "fighter" that drifts in from the right edge of
## the screen. Main.gd tunes speed/health/fire behavior per spawn so a
## single scene produces a few different enemy "classes".

signal destroyed(points: int)

@export var speed: float = 160.0
@export var health: int = 2
@export var score_value: int = 100
@export var can_shoot: bool = true
@export var fire_interval: float = 1.8

var _fire_timer: float = 0.0

const EnemyBulletScene: PackedScene = preload("res://scenes/EnemyBullet.tscn")
const ENEMY_COLOR := Color(0.05, 0.85, 0.3, 1.0)

func _ready() -> void:
	add_to_group("enemies")
	_fire_timer = randf_range(0.4, fire_interval)

func _process(delta: float) -> void:
	position.x -= speed * delta
	if can_shoot:
		_fire_timer -= delta
		if _fire_timer <= 0.0:
			_fire_timer = fire_interval
			_shoot()
	if position.x < -60.0:
		queue_free()

func _shoot() -> void:
	var bullet := EnemyBulletScene.instantiate()
	bullet.global_position = global_position + Vector2(-20.0, 0.0)
	get_parent().add_child(bullet)

func _draw() -> void:
	var points := PackedVector2Array([
		Vector2(16, 0),
		Vector2(0, -14),
		Vector2(-16, 0),
		Vector2(0, 14),
	])
	for i in points.size():
		draw_line(points[i], points[(i + 1) % points.size()], ENEMY_COLOR, 2.0)
	draw_circle(Vector2.ZERO, 2.0, ENEMY_COLOR)

## Called by a player bullet; reduces health and dies when it hits zero.
func explode() -> void:
	health -= 1
	if health <= 0:
		destroyed.emit(score_value)
		queue_free()

## Called when the player physically rams this enemy: always instant-kill.
func ram_kill() -> void:
	destroyed.emit(score_value)
	queue_free()
