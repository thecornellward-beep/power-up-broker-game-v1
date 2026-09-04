extends Node2D
## Draws a scrolling vector grid + starfield to sell the side-scrolling
## illusion, since the player ship itself stays within the screen bounds.

@export var scroll_speed: float = 120.0
@export var grid_spacing: float = 64.0
@export var star_count: int = 70

var _offset: float = 0.0
var _stars: Array = []
var _screen_size: Vector2

func _ready() -> void:
	_screen_size = get_viewport_rect().size
	randomize()
	for i in star_count:
		_stars.append({
			"pos": Vector2(randf() * _screen_size.x, randf() * _screen_size.y),
			"speed": randf_range(50.0, 260.0),
			"size": randf_range(1.0, 2.5),
		})

func _process(delta: float) -> void:
	_offset = fmod(_offset + scroll_speed * delta, grid_spacing)
	for star in _stars:
		var pos: Vector2 = star.pos
		pos.x -= star.speed * delta
		if pos.x < 0.0:
			pos.x = _screen_size.x
			pos.y = randf() * _screen_size.y
		star.pos = pos
	queue_redraw()

func _draw() -> void:
	var grid_color := Color(0.0, 0.35, 0.12, 1.0)
	var x := -_offset
	while x < _screen_size.x:
		draw_line(Vector2(x, 0.0), Vector2(x, _screen_size.y), grid_color, 1.0)
		x += grid_spacing
	var y := 0.0
	while y < _screen_size.y:
		draw_line(Vector2(0.0, y), Vector2(_screen_size.x, y), grid_color, 1.0)
		y += grid_spacing

	var star_color := Color(0.2, 1.0, 0.4, 1.0)
	for star in _stars:
		draw_circle(star.pos, star.size, star_color)
