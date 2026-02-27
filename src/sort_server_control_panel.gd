@tool class_name SortServerControlPanel extends PanelContainer
## A panel to control a [SortServer]
##
## [SortServerDataMonitor] control is supported, by setting the
## [member monitor].

## The server to be controlled.
@export var server: SortServer
## Wheather to auto hide when mouse not hovering on.
@export var auto_hide: bool = false:
	set(v):
		auto_hide = v
		if not auto_hide:
			modulate.a = 1
## Optional monitor to handle zooming.
@export var monitor: SortServerDataMonitor:
	set(v):
		monitor = v
		_zoombox.visible = monitor != null

var _presume := Button.new()
var _speed := SpinBox.new()
var _reso := SpinBox.new()
var _type := OptionButton.new()
var _ign := CheckButton.new()
var _zoom := Zoomer.new()
var _zoombox := HBoxContainer.new()
var _tickon := Button.new()
var _ticks := Label.new()

func _ready() -> void:
	#region : Setup
	
	# other's tooltip are on icons.
	
	var _rtick := Button.new()
	_rtick.icon = preload("uid://c2eyuio8be8e6")
	_rtick.tooltip_text = "Reverse Swap"
	_rtick.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var _flip := Button.new()
	_flip.icon = preload("uid://ihh5vwuovp7w")
	_flip.tooltip_text = "Flip Speed"
	
	_presume.tooltip_text = "Pause/Resume"
	_presume.icon = preload("uid://dn5g1bbhej5g6")
	
	var _tick := Button.new()
	_tick.icon = preload("uid://d1risp5b75d7j")
	_tick.tooltip_text = "Step Forward"
	_tick.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	_ticks.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_ticks.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	_speed.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_reso.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	var _shuf := Button.new()
	_shuf.icon = preload("uid://c4a42j6omjfct")
	_shuf.tooltip_text = "Shuffle Data"
	_shuf.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	_ign.icon = preload("uid://h8dqp188myqi")
	_ign.toggle_mode = true
	
	_zoom.max_value = 1.0
	_zoom.min_value = 0.0
	_zoom.step = 0.0001
	
	#endregion : Setup
	
	#region : Lay
	
	## Add childs.
	var acs := func(node: Node, ...childs: Array) -> Node:
		for c in childs:
			node.add_child(c)
		return node
	
	## Create well sized icon.
	var ico := func(tex: CompressedTexture2D, tooltip: String = "") -> AspectRatioContainer:
		var arc := AspectRatioContainer.new()
		var b := Button.new()
		b.flat = true
		b.icon = tex
		b.tooltip_text = tooltip
		arc.add_child(b)
		return arc
	
	var switchbox: Control = acs.call(
		HBoxContainer.new(), _rtick, _flip, _presume, _tick, _shuf
	)

	var speedbox: Control = acs.call(
		HBoxContainer.new(),
		ico.call(preload("uid://57dk5h47uwwd"), "Tick per second"),
		_speed
	)

	var resobox: Control = acs.call(
		HBoxContainer.new(),
		ico.call(preload("uid://bcjswls8xtntk"), "Data Size"),
		_reso
	)
	
	var numinbox: Control = acs.call(HBoxContainer.new(), speedbox, resobox)
	
	var tickonbox := ico.call(preload("uid://bu8eomdfykgyw"), "Total Ticks") as Control
	_tickon = tickonbox.get_child(0)
	var tickbox: Control = acs.call(HBoxContainer.new(), tickonbox, _ticks)
	
	var typebox: Control = acs.call(
		HBoxContainer.new(),
		ico.call(preload("uid://1ohdm6vxstbq"), "Sorter Kind"),
		_type
	)
	
	var etcbox: Control = acs.call(HBoxContainer.new(), tickbox, typebox, _ign)
	
	_zoombox = acs.call(
		HBoxContainer.new(),
		ico.call(preload("uid://d3smin12wqlet"), "Zoom/Scroll"),
		_zoom
	)
	
	var layout: Control = acs.call(VBoxContainer.new(), switchbox, numinbox, etcbox, _zoombox)
	
	add_child(layout)
	
	#endregion : Lay
	
	#region : Space
	
	## Container Sizing.
	var cs := func(n: Control, h: int = -1, v: int = -1, s: float = 1.0) -> void:
		n.size_flags_horizontal = h
		n.size_flags_vertical = v
		n.size_flags_stretch_ratio = s
	
	cs.call(switchbox, 3, 3)
	
	cs.call(_rtick, 3, 3)
	cs.call(_flip, 1, 1)
	cs.call(_presume, 1, 1)
	cs.call(_tick, 3, 3)
	
	for n in [
		speedbox, _speed, resobox, _reso, numinbox, _shuf,
		etcbox, tickbox, _ticks, typebox, _type,
		_zoombox, _zoom,
	] as Array[Control]:
		cs.call(n, 3, 3)
	
	#endregion : Space
	
	monitor = monitor # refresh on ready.
	
	#region : Connect
	
	if Engine.is_editor_hint(): return
	
	_rtick.pressed.connect(server.reverse_swap)
	
	_flip.pressed.connect(func():
		server.tick_speed = -server.tick_speed
	)
	
	_presume.pressed.connect(func():
		server.paused = not server.paused
		_presume.icon = [
			preload("uid://b0i4ofdvei56n"),
			preload("uid://dn5g1bbhej5g6"),
		][int(server.paused)]
	)
	
	_tick.pressed.connect(server.sort_step)
	
	_speed.value_changed.connect(func(v: float):
		server.tick_speed = v
	)
	
	_reso.value_changed.connect(func(v: int):
		server.resolution = v
	)
	
	_shuf.pressed.connect(server.shuffle)
	
	_type.item_selected.connect(func(idx: int):
		server.sorter = server.sorters[idx]
	)
	
	_ign.toggled.connect(func(tog: bool):
		server.ignore_visup = tog
	)
	
	var zoomup := func():
		monitor.zoom = _zoom.page
		monitor.scroll = _zoom.value
	_zoom.changed.connect(zoomup)
	_zoom.value_changed.connect(zoomup.unbind(1))
	
	#endregion : Connect
	
	_up()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_tickon.icon = preload("uid://bu8eomdfykgyw")
		_ticks.text = "%04d" % 0
		return
	
	if auto_hide:
		if (
			get_global_rect().abs().has_point(get_global_mouse_position()) or
			_zoom._clk
		):
			modulate.a = move_toward(modulate.a, 1, delta * 2)
		else:
			modulate.a = move_toward(modulate.a, 0, delta * 2)
	
	_tickon.icon = [
		preload("uid://bu8eomdfykgyw"),
		preload("uid://bttt21ve287i7"),
		preload("uid://cpqwx030fyuca"),
		preload("uid://727mou2q30cq"),
		preload("uid://x8xm7h7fnlsr"),
		preload("uid://cj5ayod5lefly"),
		preload("uid://bhdcr4da3gi8j"),
		preload("uid://bkviwy4r23f2u"),
	][server.ticked % 8]
	_ticks.text = "%04d" % server.ticked

# sync with the server
func _up() -> void:
	_presume.icon = [
		preload("uid://b0i4ofdvei56n"),
		preload("uid://dn5g1bbhej5g6"),
	][int(server.paused)]
	
	_speed.set_value_no_signal(server.tick_speed)
	_reso.set_value_no_signal(server.resolution)
	
	_type.clear()
	for sorter in server.sorters:
		var s = sorter.get_script()
		if s is GDScript:
			var nom = s.get_global_name().capitalize()
			var re := RegEx.create_from_string(r'(?<=\n|^)(?<!#)\s*?@icon\("(?<icon>.*?)"\)(?=\n|$)')
			var mat := re.search(s.source_code)
			
			if mat:
				_type.add_icon_item(load(mat.get_string("icon")), nom)
			
			else:
				_type.add_icon_item(preload("uid://1ohdm6vxstbq"), nom)
		
	_type.selected = server.sorters.find(server.sorter)
	_ign.button_pressed = server.ignore_visup
	
	if monitor:
		_zoom.value = monitor.scroll
		_zoom.page = monitor.zoom
