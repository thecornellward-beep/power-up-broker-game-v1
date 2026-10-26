extends Node2D
## A jagged mountain-range silhouette used as a parallax backdrop layer.
## Two instances (far/near) with different heights, colors and
## ParallaxLayer motion_scale values create a sense of depth.

@export var peak_color: Color = Color(0.12, 0.12, 0.2, 1.0)
@export var base_height: float = 420.0
@export var jaggedness: float = 90.0
@export var segment_width: float = 180.0
@export var span: float = 6000.0

var _points: PackedVector2Array = PackedVector2Array()

func _ready() -> void:
	_generate()
	queue_redraw()

func _generate() -> void:
	_points.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = int(base_height * 1000.0 + jaggedness)
	var x := -400.0
	while x < span:
		var h := base_height - rng.randf_range(0.0, jaggedness)
		_points.append(Vector2(x, h))
		x += segment_width

func _draw() -> void:
	if _points.size() < 2:
		return
	var poly := PackedVector2Array()
	poly.append(Vector2(_points[0].x, 700.0))
	for p in _points:
		poly.append(p)
	poly.append(Vector2(_points[_points.size() - 1].x, 700.0))
	draw_colored_polygon(poly, peak_color)
