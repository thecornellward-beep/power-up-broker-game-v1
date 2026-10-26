extends Area2D

@export var speed: float = 320.0
var direction: float = -1.0
var _lifetime: float = 3.0

const BULLET_COLOR := Color(0.75, 0.25, 0.85, 1.0)

func _ready() -> void:
	add_to_group("enemy_bullets")
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position.x += direction * speed * delta
	_lifetime -= delta
	if _lifetime <= 0.0:
		queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 4.0, BULLET_COLOR)
	draw_circle(Vector2.ZERO, 2.0, Color(1.0, 0.8, 1.0, 1.0))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("hit"):
		body.hit()
		queue_free()
	elif body.is_in_group("terrain"):
		queue_free()
