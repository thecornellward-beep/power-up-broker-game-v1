extends Node2D
## Static dusk sky backdrop: a moon and a scattering of stars, drawn once.

const MOON_COLOR := Color(0.85, 0.85, 0.72, 1.0)
const STAR_COLOR := Color(1.0, 1.0, 1.0, 0.85)

var _stars: PackedVector2Array = PackedVector2Array()
var _star_sizes: PackedFloat32Array = PackedFloat32Array()

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1337
	for i in 90:
		_stars.append(Vector2(rng.randf_range(-400.0, 6400.0), rng.randf_range(0.0, 320.0)))
		_star_sizes.append(rng.randf_range(0.8, 2.2))
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2(760.0, 110.0), 46.0, MOON_COLOR)
	draw_circle(Vector2(760.0, 110.0), 52.0, Color(MOON_COLOR.r, MOON_COLOR.g, MOON_COLOR.b, 0.15))
	for i in _stars.size():
		draw_circle(_stars[i], _star_sizes[i], STAR_COLOR)
