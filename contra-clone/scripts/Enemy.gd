extends Area2D
## A bipedal alien trooper: patrols a short stretch of ground until the
## player comes within range, then plants its feet and opens fire.

signal destroyed(points: int)

@export var health: int = 1
@export var score_value: int = 150
@export var patrol_range: float = 60.0
@export var patrol_speed: float = 40.0
@export var aggro_range: float = 420.0
@export var aggro_vertical: float = 160.0
@export var fire_interval: float = 1.3
@export var bullet_speed: float = 320.0

var _spawn_x: float = 0.0
var _patrol_dir: float = 1.0
var _fire_timer: float = 0.0
var _facing: float = -1.0
var _anim_time: float = 0.0
var _player: Node2D = null
var _aggro: bool = false

const EnemyBulletScene: PackedScene = preload("res://scenes/EnemyBullet.tscn")
const SKIN := Color(0.30, 0.78, 0.40, 1.0)
const SUIT := Color(0.14, 0.42, 0.26, 1.0)
const EYE := Color(0.05, 0.05, 0.08, 1.0)

func _ready() -> void:
	add_to_group("enemies")
	body_entered.connect(_on_body_entered)
	_spawn_x = position.x
	_fire_timer = randf_range(0.3, fire_interval)
	var nodes := get_tree().get_nodes_in_group("player")
	if nodes.size() > 0:
		_player = nodes[0]

func _process(delta: float) -> void:
	_anim_time += delta
	if _player == null or not is_instance_valid(_player):
		_patrol(delta)
		queue_redraw()
		return

	var dx := _player.global_position.x - global_position.x
	var dy := _player.global_position.y - global_position.y
	_aggro = abs(dx) < aggro_range and abs(dy) < aggro_vertical

	if _aggro:
		_facing = 1.0 if dx > 0.0 else -1.0
		_fire_timer -= delta
		if _fire_timer <= 0.0:
			_fire_timer = fire_interval
			_shoot()
	else:
		_patrol(delta)
	queue_redraw()

func _patrol(delta: float) -> void:
	position.x += _patrol_dir * patrol_speed * delta
	_facing = _patrol_dir
	if position.x > _spawn_x + patrol_range:
		_patrol_dir = -1.0
	elif position.x < _spawn_x - patrol_range:
		_patrol_dir = 1.0

func _shoot() -> void:
	var bullet := EnemyBulletScene.instantiate()
	bullet.direction = _facing
	bullet.speed = bullet_speed
	bullet.global_position = global_position + Vector2(_facing * 16.0, -22.0)
	get_parent().add_child(bullet)

func _draw() -> void:
	var walk := sin(_anim_time * 8.0) * 8.0 if not _aggro else 0.0
	var f := _facing

	draw_line(Vector2(-4, -18), Vector2(-4 + walk, 0), SUIT, 4.0)
	draw_line(Vector2(4, -18), Vector2(4 - walk, 0), SUIT, 4.0)
	draw_line(Vector2(0, -34), Vector2(0, -18), SUIT, 7.0)
	draw_line(Vector2(0, -30), Vector2(f * 12.0, -22.0), SKIN, 3.5)
	if _aggro:
		draw_line(Vector2(f * 12.0, -22.0), Vector2(f * 22.0, -22.0), Color(0.1, 0.1, 0.1, 1.0), 2.5)
	draw_circle(Vector2(0, -42), 8.0, SKIN)
	draw_circle(Vector2(f * 3.0, -43.0), 2.6, EYE)
	draw_circle(Vector2(f * -1.0, -43.0), 2.2, EYE)

## Called by a player bullet.
func explode() -> void:
	health -= 1
	if health <= 0:
		destroyed.emit(score_value)
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("hit"):
		body.hit()
