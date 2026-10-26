extends Area2D
## Stage-end gate. Fires `reached` when the player walks into it.

signal reached

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _draw() -> void:
	var stone := Color(0.32, 0.32, 0.34, 1.0)
	var dark := Color(0.16, 0.16, 0.18, 1.0)
	draw_rect(Rect2(-50, -220, 20, 220), stone)
	draw_rect(Rect2(30, -220, 20, 220), stone)
	draw_rect(Rect2(-50, -244, 100, 24), dark)
	draw_line(Vector2(40, -244), Vector2(40, -300), Color(0.6, 0.6, 0.6, 1.0), 3.0)
	draw_colored_polygon(PackedVector2Array([
		Vector2(40, -300), Vector2(78, -288), Vector2(40, -276),
	]), Color(0.78, 0.1, 0.1, 1.0))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		reached.emit()
