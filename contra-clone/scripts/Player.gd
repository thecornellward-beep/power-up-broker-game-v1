extends CharacterBody2D
## Commando-style player character: run, jump, crouch, and fire a
## rapid machine gun (forward, or straight up while standing/airborne).
## No InputMap entries are required — raw key checks keep this project
## runnable without editor-side setup.

signal hit_player

@export var move_speed: float = 220.0
@export var jump_velocity: float = -520.0
@export var gravity: float = 1400.0
@export var fire_rate: float = 0.09

enum State { IDLE, RUN, JUMP, CROUCH }

var facing: float = 1.0
var state: State = State.IDLE
var _fire_cooldown: float = 0.0
var _invincible_time: float = 0.0
var _anim_time: float = 0.0
var _muzzle_flash: float = 0.0
var _dead: bool = false
var _jump_queued: bool = false
var _is_crouching: bool = false
var _is_aiming_up: bool = false

const BulletScene: PackedScene = preload("res://scenes/PlayerBullet.tscn")

const SKIN := Color(0.86, 0.64, 0.46, 1.0)
const FATIGUES := Color(0.27, 0.33, 0.18, 1.0)
const BOOTS := Color(0.13, 0.11, 0.09, 1.0)
const HEADBAND := Color(0.75, 0.08, 0.08, 1.0)
const GUN_COLOR := Color(0.16, 0.16, 0.18, 1.0)
const BELT := Color(0.2, 0.2, 0.2, 1.0)

@onready var stand_collision: CollisionShape2D = $StandCollision
@onready var crouch_collision: CollisionShape2D = $CrouchCollision

func _ready() -> void:
	add_to_group("player")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		_jump_queued = true

## Called by Main.gd after a death to put the player back in play.
func respawn_at(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	_dead = false
	_invincible_time = 1.2
	visible = true

func _physics_process(delta: float) -> void:
	if _dead:
		return

	_is_crouching = (Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S)) and is_on_floor()
	_is_aiming_up = (Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W)) and not _is_crouching

	var input_dir := 0.0
	if not _is_crouching:
		if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
			input_dir -= 1.0
		if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
			input_dir += 1.0

	if input_dir != 0.0:
		facing = sign(input_dir)
	velocity.x = input_dir * move_speed

	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor() and _jump_queued and not _is_crouching:
		velocity.y = jump_velocity
	_jump_queued = false

	move_and_slide()

	if not is_on_floor():
		state = State.JUMP
	elif _is_crouching:
		state = State.CROUCH
	elif input_dir != 0.0:
		state = State.RUN
	else:
		state = State.IDLE

	_anim_time += delta
	_handle_shooting(delta)

	if _invincible_time > 0.0:
		_invincible_time -= delta
		modulate.a = 0.4 if int(_invincible_time * 14.0) % 2 == 0 else 1.0
	else:
		modulate.a = 1.0

	stand_collision.disabled = _is_crouching
	crouch_collision.disabled = not _is_crouching

	if global_position.y > 1100.0:
		hit()

	queue_redraw()

func _handle_shooting(delta: float) -> void:
	_fire_cooldown -= delta
	_muzzle_flash -= delta
	if Input.is_key_pressed(KEY_X) and _fire_cooldown <= 0.0:
		_fire_cooldown = fire_rate
		_muzzle_flash = 0.06
		_fire_bullet()

func _fire_bullet() -> void:
	var bullet := BulletScene.instantiate()
	var aim_dir: Vector2
	var spawn: Vector2
	if _is_aiming_up:
		aim_dir = Vector2(0.0, -1.0)
		spawn = Vector2(0.0, -48.0)
	elif _is_crouching:
		aim_dir = Vector2(facing, 0.0)
		spawn = Vector2(facing * 16.0, -14.0)
	else:
		aim_dir = Vector2(facing, 0.0)
		spawn = Vector2(facing * 20.0, -28.0)
	bullet.aim_dir = aim_dir
	bullet.global_position = global_position + spawn
	get_parent().add_child(bullet)

## Called externally by enemies/enemy bullets/falling off the world.
func hit() -> void:
	if _invincible_time > 0.0 or _dead:
		return
	_dead = true
	visible = false
	hit_player.emit()

func _draw() -> void:
	match state:
		State.CROUCH:
			_draw_crouch()
		State.JUMP:
			_draw_jump()
		State.RUN:
			_draw_run()
		_:
			_draw_idle()
	_draw_arms_and_gun()
	if _muzzle_flash > 0.0:
		_draw_muzzle_flash()

func _draw_legs(hip_y: float, swing: float) -> void:
	draw_line(Vector2(-4, hip_y), Vector2(-4 - swing, 0), FATIGUES, 6.0)
	draw_line(Vector2(4, hip_y), Vector2(4 + swing, 0), FATIGUES, 6.0)
	draw_line(Vector2(-4 - swing, -4), Vector2(-4 - swing, 0), BOOTS, 7.0)
	draw_line(Vector2(4 + swing, -4), Vector2(4 + swing, 0), BOOTS, 7.0)

func _draw_torso_head(hip_y: float, head_y: float) -> void:
	draw_line(Vector2(0, hip_y), Vector2(0, head_y + 9), FATIGUES, 10.0)
	draw_line(Vector2(-7, hip_y + 3), Vector2(7, hip_y + 3), BELT, 3.0)
	draw_circle(Vector2(0, head_y), 7.0, SKIN)
	var f := facing
	draw_line(Vector2(f * -6, head_y - 5), Vector2(f * 7, head_y - 4), HEADBAND, 3.0)
	draw_line(Vector2(f * -6, head_y - 5), Vector2(f * -13, head_y + 1), HEADBAND, 2.0)
	draw_line(Vector2(f * -5, head_y - 3), Vector2(f * -14, head_y + 6), HEADBAND, 2.0)

func _draw_idle() -> void:
	var bob := sin(_anim_time * 3.0) * 1.0
	_draw_legs(-20.0, 0.0)
	_draw_torso_head(-20.0 + bob, -40.0 + bob)

func _draw_run() -> void:
	var swing := sin(_anim_time * 16.0) * 7.0
	_draw_legs(-20.0, swing)
	_draw_torso_head(-20.0, -40.0)

func _draw_jump() -> void:
	_draw_legs(-20.0, -4.0)
	_draw_torso_head(-20.0, -40.0)

func _draw_crouch() -> void:
	_draw_legs(-10.0, 6.0)
	_draw_torso_head(-10.0, -26.0)

func _draw_arms_and_gun() -> void:
	var f := facing
	var shoulder_y := -26.0 if not _is_crouching else -16.0
	var hand: Vector2
	var gun_dir: Vector2
	if _is_aiming_up:
		hand = Vector2(0.0, shoulder_y - 16.0)
		gun_dir = Vector2(0.0, -1.0)
	else:
		hand = Vector2(f * 14.0, shoulder_y)
		gun_dir = Vector2(f, 0.0)
	draw_line(Vector2(0, shoulder_y), hand, SKIN, 3.5)
	draw_line(hand, hand + gun_dir * 18.0, GUN_COLOR, 3.0)

func _draw_muzzle_flash() -> void:
	var f := facing
	var shoulder_y := -26.0 if not _is_crouching else -16.0
	var tip: Vector2
	if _is_aiming_up:
		tip = Vector2(0.0, shoulder_y - 34.0)
	else:
		tip = Vector2(f * 32.0, shoulder_y)
	draw_circle(tip, 4.0, Color(1.0, 0.9, 0.4, 0.9))
