extends Area2D

@export var speed: float = 1000.0
var aim_dir: Vector2 = Vector2.RIGHT
var _lifetime: float = 1.2

const BULLET_COLOR := Color(1.0, 0.95, 0.4, 1.0)

func _ready() -> void:
	add_to_group("player_bullets")
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position += aim_dir * speed * delta
	_lifetime -= delta
	if _lifetime <= 0.0:
		queue_free()

func _draw() -> void:
	draw_line(-aim_dir * 7.0, aim_dir * 7.0, BULLET_COLOR, 2.5)
	draw_circle(aim_dir * 7.0, 1.5, BULLET_COLOR)

func _on_area_entered(area: Node2D) -> void:
	if area.is_in_group("enemies") and area.has_method("explode"):
		area.explode()
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("terrain"):
		queue_free()
