extends Node2D

const EnemyScene: PackedScene = preload("res://scenes/Enemy.tscn")

@export var spawn_interval_start: float = 1.4
@export var spawn_interval_min: float = 0.5

var score: int = 0
var game_over: bool = false
var _spawn_timer: float = 0.0
var _spawn_interval: float = 1.4

@onready var player: Area2D = $Player
@onready var score_label: Label = $HUD/ScoreLabel
@onready var lives_label: Label = $HUD/LivesLabel
@onready var game_over_label: Label = $HUD/GameOverLabel

func _ready() -> void:
	randomize()
	_spawn_interval = spawn_interval_start
	player.died.connect(_on_player_died)
	player.lives_changed.connect(_on_lives_changed)
	game_over_label.visible = false
	_update_score_label()
	_on_lives_changed(player.lives)

func _process(delta: float) -> void:
	if game_over:
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = _spawn_interval
		_spawn_interval = max(spawn_interval_min, _spawn_interval - 0.02)
		_spawn_enemy()

func _unhandled_input(event: InputEvent) -> void:
	if game_over and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			get_tree().reload_current_scene()

func _spawn_enemy() -> void:
	var enemy := EnemyScene.instantiate()
	var screen_size := get_viewport_rect().size
	enemy.position = Vector2(screen_size.x + 40.0, randf_range(40.0, screen_size.y - 40.0))

	var roll := randf()
	if roll < 0.35:
		enemy.speed = randf_range(220.0, 300.0)
		enemy.can_shoot = false
		enemy.health = 1
		enemy.score_value = 50
	elif roll < 0.75:
		enemy.speed = randf_range(120.0, 180.0)
		enemy.can_shoot = true
		enemy.health = 2
		enemy.score_value = 100
	else:
		enemy.speed = randf_range(80.0, 120.0)
		enemy.can_shoot = true
		enemy.fire_interval = 1.2
		enemy.health = 3
		enemy.score_value = 200
		enemy.scale = Vector2(1.4, 1.4)

	enemy.destroyed.connect(_on_enemy_destroyed)
	add_child(enemy)

func _on_enemy_destroyed(points: int) -> void:
	score += points
	_update_score_label()

func _on_lives_changed(lives: int) -> void:
	lives_label.text = "LIVES %d" % lives

func _on_player_died() -> void:
	game_over = true
	game_over_label.visible = true
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.set_process(false)

func _update_score_label() -> void:
	score_label.text = "SCORE %06d" % score
