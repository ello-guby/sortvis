@tool class_name Zoomer extends Range
## A scroll that zoom and scroll horizontally.

var _hov := false # if hovering.
var _clk := false # if clicked.
var _scrlbox := Vector2.ZERO # scroller x (pos, size): 
var _init_mscrlboxpos := Vector2.ZERO # click position.
var _mpos := Vector2.ZERO # last frame mouse position.
var _y := 1.0: # zoom relative.
	set(v): _y = clampf(v, 0, 1)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			if _hov and event.is_pressed():
				var mpos := get_local_mouse_position()
				if _rndr_scrlbox().abs().has_point(mpos):
					_clk = true
					_init_mscrlboxpos = Vector2(mpos.x - _scrlbox.x, _y * size.x)
					_mpos = mpos
				
				elif Rect2(Vector2.ZERO, size).abs().has_point(mpos):
					@warning_ignore("narrowing_conversion")
					var dir := signi(mpos.x - _scrlbox.x)
					value += page * dir
			
			if event.is_released():
				_clk = false

func _ready() -> void:
	# connect
	mouse_entered.connect(func(): _hov = true)
	mouse_exited.connect(func(): _hov = false)

func _process(_delta: float) -> void:
	if _clk:
		_scrlbox_mpos()
	else:
		_scrlbox_val()
	
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
	draw_style_box(get_theme_stylebox(grabber, "HScrollBar"), _rndr_scrlbox())

# update _scrlbox with mposes
func _scrlbox_mpos() -> void:
	var mpos := get_local_mouse_position()
	var mrel := _mpos - mpos ## Mouse relative
	
	_init_mscrlboxpos.y += mrel.y * 2
	_y = _init_mscrlboxpos.y / size.x
	var shift := _y * size.x
	if _y > 0: _init_mscrlboxpos.x += mrel.y
	
	var ptb := clampf(shift, 0, size.x)
	var pta := clampf(mpos.x - _init_mscrlboxpos.x, 0, size.x - ptb)
	
	_scrlbox = Vector2(pta, ptb)
	_mpos = mpos
	
	page = _y * (max_value - min_value)
	value = ((_scrlbox.x / size.x) * (max_value - min_value))

# update _sclbox with values.
func _scrlbox_val() -> void:
	_scrlbox = Vector2(
		(value - min_value) * size.x / (max_value - min_value),
		page / (max_value - min_value) * size.x
	)

# return renderable scrlbox shape
func _rndr_scrlbox() -> Rect2:
	var y := clampf(_scrlbox.y, size.y, size.x)
	var x := clampf(_scrlbox.x, 0, size.x - y)
	return Rect2(Vector2(x, 0), Vector2(y, size.y))
