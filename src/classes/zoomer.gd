@tool class_name Zoomer extends Range
## A scroll that zoom and scroll.

var _hov := false
var _clk := false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			if _hov and event.is_pressed():
				_clk = true
			if event.is_released():
				_clk = false
	if event is InputEventMouseMotion:
		if _clk:
			var rel: Vector2 = event.relative * ((max_value - min_value) / size.x)
			page -= rel.y
			if page > 0: value += rel.y / 4
			value += rel.x

func _ready() -> void:
	mouse_entered.connect(func(): _hov = true)
	mouse_exited.connect(func(): _hov = false)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var scroll := "scroll"
	var grabber := "grabber"
	if has_focus(): scroll += "_focus"
	if _clk:
		grabber += "_pressed"
	elif _hov:
		grabber += "_highlight"
	draw_style_box(get_theme_stylebox(scroll, "HScrollBar"), Rect2(Vector2.ZERO, size))
	draw_style_box(get_theme_stylebox(grabber, "HScrollBar"), Rect2(Vector2(
		(value - min_value / max_value - min_value) * size.x, 0
	), Vector2(
		max((page - min_value / max_value - min_value) * size.x, 5), size.y
	)))
