extends Node2D

const EnemyScene: PackedScene = preload("res://scenes/Enemy.tscn")
const TerrainChunkScript := preload("res://scripts/TerrainChunk.gd")

const START_LIVES: int = 3

## Stepped mountain profile: each entry is a flat slab of ground.
## Gaps between entries (e.g. 1300-1420) are chasms the player must jump.
const GROUND_SEGMENTS := [
	{"x": 0,    "width": 500, "top": 500},
	{"x": 500,  "width": 550, "top": 430},
	{"x": 1050, "width": 250, "top": 500},
	{"x": 1420, "width": 330, "top": 500},
	{"x": 1750, "width": 150, "top": 430},
	{"x": 1900, "width": 250, "top": 350},
	{"x": 2150, "width": 400, "top": 350},
	{"x": 2550, "width": 150, "top": 430},
	{"x": 2700, "width": 150, "top": 500},
	{"x": 2850, "width": 250, "top": 500},
	{"x": 3230, "width": 270, "top": 460},
	{"x": 3500, "width": 150, "top": 380},
	{"x": 3650, "width": 350, "top": 380},
	{"x": 4000, "width": 150, "top": 460},
	{"x": 4150, "width": 650, "top": 460},
]

const CHECKPOINTS := [
	Vector2(100, 460),
	Vector2(1450, 460),
	Vector2(2200, 310),
	Vector2(3260, 420),
	Vector2(3700, 340),
]

const ENEMY_SPAWNS := [
	{"pos": Vector2(900, 430), "health": 1},
	{"pos": Vector2(1600, 500), "health": 1},
	{"pos": Vector2(2020, 350), "health": 1},
	{"pos": Vector2(2300, 350), "health": 2},
	{"pos": Vector2(2450, 350), "health": 1},
	{"pos": Vector2(2950, 500), "health": 1},
	{"pos": Vector2(3350, 460), "health": 1},
	{"pos": Vector2(3550, 380), "health": 2},
	{"pos": Vector2(3800, 380), "health": 1},
	{"pos": Vector2(3900, 380), "health": 2},
]

const LEVEL_WIDTH: float = 4800.0
const GOAL_X: float = 4650.0
const GOAL_TOP: float = 460.0

var score: int = 0
var lives_left: int = START_LIVES
var current_checkpoint: int = 0
var game_over: bool = false
var stage_clear: bool = false

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D
@onready var terrain_root: Node2D = $Terrain
@onready var enemies_root: Node2D = $Enemies
@onready var goal: Area2D = $Goal
@onready var score_label: Label = $HUD/ScoreLabel
@onready var lives_label: Label = $HUD/LivesLabel
@onready var message_label: Label = $HUD/MessageLabel

func _ready() -> void:
	randomize()
	_build_terrain()
	_spawn_enemies()
	player.hit_player.connect(_on_player_hit)
	goal.reached.connect(_on_goal_reached)
	goal.position = Vector2(GOAL_X, GOAL_TOP)
	lives_left = START_LIVES
	message_label.visible = false
	_update_score_label()
	_update_lives_label()
	camera.limit_left = 0
	camera.limit_right = int(LEVEL_WIDTH)
	camera.limit_top = -200
	camera.limit_bottom = 650

func _build_terrain() -> void:
	for seg in GROUND_SEGMENTS:
		var chunk := StaticBody2D.new()
		chunk.set_script(TerrainChunkScript)
		terrain_root.add_child(chunk)
		chunk.position = Vector2(seg.x + seg.width / 2.0, seg.top)
		chunk.setup(seg.width, 400.0)

func _spawn_enemies() -> void:
	for spec in ENEMY_SPAWNS:
		var enemy := EnemyScene.instantiate()
		enemy.position = spec.pos
		enemy.health = spec.health
		enemy.destroyed.connect(_on_enemy_destroyed)
		enemies_root.add_child(enemy)

func _process(_delta: float) -> void:
	if game_over or stage_clear:
		return
	_update_checkpoint()
	camera.global_position = Vector2(player.global_position.x, 300.0)

func _update_checkpoint() -> void:
	for i in range(CHECKPOINTS.size() - 1, -1, -1):
		if player.global_position.x >= CHECKPOINTS[i].x:
			current_checkpoint = max(current_checkpoint, i)
			break

func _unhandled_input(event: InputEvent) -> void:
	if (game_over or stage_clear) and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			get_tree().reload_current_scene()

func _on_enemy_destroyed(points: int) -> void:
	score += points
	_update_score_label()

func _on_player_hit() -> void:
	lives_left -= 1
	_update_lives_label()
	if lives_left <= 0:
		game_over = true
		message_label.text = "GAME OVER\nPRESS SPACE TO RESTART"
		message_label.visible = true
		player.set_physics_process(false)
	else:
		player.respawn_at(CHECKPOINTS[current_checkpoint])

func _on_goal_reached() -> void:
	if stage_clear:
		return
	stage_clear = true
	message_label.text = "STAGE 1 CLEAR!\nPRESS SPACE TO RESTART"
	message_label.visible = true
	player.set_physics_process(false)

func _update_score_label() -> void:
	score_label.text = "SCORE %06d" % score

func _update_lives_label() -> void:
	lives_label.text = "LIVES %d" % lives_left
