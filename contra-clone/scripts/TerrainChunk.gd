extends StaticBody2D
## A solid ground slab used to build the stepped, mountainous level
## profile. Main.gd instantiates one of these per entry in its
## GROUND_SEGMENTS table and calls setup() to size it.

var chunk_width: float = 200.0
var chunk_height: float = 400.0

const ROCK_MID := Color(0.26, 0.22, 0.19, 1.0)
const ROCK_DARK := Color(0.16, 0.14, 0.13, 1.0)
const RIDGE := Color(0.36, 0.44, 0.28, 1.0)

func setup(width: float, height: float) -> void:
	chunk_width = width
	chunk_height = height
	add_to_group("terrain")
	collision_layer = 16
	collision_mask = 0
	var shape := RectangleShape2D.new()
	shape.size = Vector2(chunk_width, chunk_height)
	var cs := CollisionShape2D.new()
	cs.shape = shape
	cs.position = Vector2(0.0, chunk_height / 2.0)
	add_child(cs)
	queue_redraw()

func _draw() -> void:
	var half_w := chunk_width / 2.0
	draw_rect(Rect2(-half_w, 0.0, chunk_width, chunk_height), ROCK_MID)

	var strata_y := 18.0
	while strata_y < chunk_height:
		draw_line(Vector2(-half_w, strata_y), Vector2(half_w, strata_y), ROCK_DARK, 2.0)
		strata_y += 46.0

	draw_line(Vector2(-half_w, 0.0), Vector2(half_w, 0.0), RIDGE, 4.0)

	var tuft_x := -half_w + 14.0
	while tuft_x < half_w - 14.0:
		draw_line(Vector2(tuft_x, 0.0), Vector2(tuft_x - 4.0, -8.0), RIDGE, 2.0)
		draw_line(Vector2(tuft_x, 0.0), Vector2(tuft_x + 4.0, -9.0), RIDGE, 2.0)
		tuft_x += 36.0
