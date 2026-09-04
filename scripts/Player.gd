extends Area2D
## Player ship: a hand-drawn vector wireframe, moved with arrows/WASD,
## firing with Space. No InputMap entries are required — raw key checks
## keep this project runnable without editor-side setup.

signal died
signal lives_changed(lives: int)

@export var speed: float = 420.0
@export var fire_rate: float = 0.18
@export var max_lives: int = 3

var lives: int = 0
var _fire_cooldown: float = 0.0
var _invincible_time: float = 0.0
var _screen_size: Vector2

const BulletScene: PackedScene = preload("res://scenes/PlayerBullet.tscn")
const SHIP_COLOR := Color(0.2, 1.0, 0.35, 1.0)

func _ready() -> void:
	_screen_size = get_viewport_rect().size
	lives = max_lives
	add_to_group("player")

func _process(delta: float) -> void:
	_handle_movement(delta)
	_handle_shooting(delta)
	if _invincible_time > 0.0:
		_invincible_time -= delta
		modulate.a = 0.35 if int(_invincible_time * 12.0) % 2 == 0 else 1.0
	else:
		modulate.a = 1.0
	queue_redraw()

func _handle_movement(delta: float) -> void:
	var dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
		dir.y -= 1.0
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		dir.y += 1.0
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		dir.x -= 1.0
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		dir.x += 1.0
	if dir.length() > 0.0:
		dir = dir.normalized()
	position += dir * speed * delta
	position.x = clamp(position.x, 24.0, _screen_size.x - 24.0)
	position.y = clamp(position.y, 24.0, _screen_size.y - 24.0)

func _handle_shooting(delta: float) -> void:
	_fire_cooldown -= delta
	if Input.is_key_pressed(KEY_SPACE) and _fire_cooldown <= 0.0:
		_fire_cooldown = fire_rate
		var bullet := BulletScene.instantiate()
		bullet.global_position = global_position + Vector2(24.0, 0.0)
		get_parent().add_child(bullet)

func _draw() -> void:
	var hull := PackedVector2Array([
		Vector2(22, 0),
		Vector2(-16, -13),
		Vector2(-8, 0),
		Vector2(-16, 13),
	])
	for i in hull.size():
		draw_line(hull[i], hull[(i + 1) % hull.size()], SHIP_COLOR, 2.0)
	draw_line(Vector2(-8, 0), Vector2(-18, 0), SHIP_COLOR, 2.0)
	draw_line(Vector2(-4, -5), Vector2(-4, 5), SHIP_COLOR, 1.5)

func hit(damage: int = 1) -> void:
	if _invincible_time > 0.0:
		return
	lives -= damage
	lives_changed.emit(lives)
	_invincible_time = 1.5
	if lives <= 0:
		died.emit()

func _on_area_entered(area: Node2D) -> void:
	if area.is_in_group("enemies") and area.has_method("ram_kill"):
		area.ram_kill()
	hit()
