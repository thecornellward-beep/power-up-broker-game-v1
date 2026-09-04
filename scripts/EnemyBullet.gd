extends Area2D

var speed: float = 500.0

const BULLET_COLOR := Color(0.15, 1.0, 0.45, 1.0)

func _ready() -> void:
	add_to_group("enemy_bullets")

func _process(delta: float) -> void:
	position.x -= speed * delta
	if position.x < -40.0:
		queue_free()

func _draw() -> void:
	draw_line(Vector2(-6, 0), Vector2(6, 0), BULLET_COLOR, 3.0)
	draw_circle(Vector2(-6, 0), 1.5, BULLET_COLOR)

func _on_area_entered(area: Node2D) -> void:
	if area.is_in_group("player"):
		queue_free()
