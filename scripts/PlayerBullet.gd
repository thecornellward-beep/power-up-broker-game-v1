extends Area2D

var speed: float = 900.0
var _screen_width: float = 1024.0

const BULLET_COLOR := Color(0.6, 1.0, 0.6, 1.0)

func _ready() -> void:
	_screen_width = get_viewport_rect().size.x
	add_to_group("player_bullets")

func _process(delta: float) -> void:
	position.x += speed * delta
	if position.x > _screen_width + 40.0:
		queue_free()

func _draw() -> void:
	draw_line(Vector2(-8, 0), Vector2(8, 0), BULLET_COLOR, 3.0)
	draw_circle(Vector2(8, 0), 1.5, BULLET_COLOR)

func _on_area_entered(area: Node2D) -> void:
	if area.is_in_group("enemies") and area.has_method("explode"):
		area.explode()
		queue_free()
