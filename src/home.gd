extends Control

var sorters: Array[Sorter] = []

@onready var panel: PanelContainer = $Panel
@onready var tick: Button = $Panel/Control/MainBox/UniBox/SwitchBox/Tick
@onready var reverse_tick: Button = $Panel/Control/MainBox/UniBox/SwitchBox/ReverseTick
@onready var flip: Button = $Panel/Control/MainBox/UniBox/SwitchBox/Flip
@onready var pause_resume: Button = $Panel/Control/MainBox/UniBox/SwitchBox/PauseResume
@onready var speed: SpinBox = $Panel/Control/MainBox/UniBox/SpeedBox/Speed
@onready var resolution: SpinBox = $Panel/Control/MainBox/UniBox/ResolutionBox/Resolution
@onready var shuffle: Button = $Panel/Control/MainBox/Shuffle
@onready var ticks: Label = $Panel/Control/SecBox/TickBox/TickPanel/Ticks
@onready var tick_load: Button = $Panel/Control/SecBox/TickBox/IconBox/TickIcon
@onready var sorter_type: OptionButton = $Panel/Control/SecBox/TypeBox/SorterType
@onready var ignore_visup: CheckButton = $Panel/Control/SecBox/IgnoreBox/IgnoreVisup
@onready var zoom: Zoomer = $Panel/Control/ZoomBox/Zoom
@onready var monitor: SortServerDataMonitor = $Monitor
@onready var server: SortServer = $SortServer

func _ready() -> void:
	# updates
	_up()
	server.resolution_changed.connect(_up.unbind(1))
	
	# init sorters
	sorters = Lib.probe_sorters()
	
	sorter_type.clear()
	for sorter in sorters:
		var s = sorter.get_script()
		if s is GDScript:
			var nom = s.get_global_name().capitalize()
			var re := RegEx.create_from_string(r'(?<=\n|^)(?<!#)\s*?@icon\("(?<icon>.*?)"\)(?=\n|$)')
			var mat := re.search(s.source_code)
			if mat:
				sorter_type.add_icon_item(load(mat.get_string("icon")), nom)
			else:
				sorter_type.add_icon_item(preload("uid://1ohdm6vxstbq"), nom)
	server.sorter = sorters[0]
	
	# control connections
	pause_resume.pressed.connect(func():
		if server.paused:
			server.paused = false
			pause_resume.icon = preload("uid://b0i4ofdvei56n")
		else:
			server.paused = true
			pause_resume.icon = preload("uid://dn5g1bbhej5g6")
	)
	reverse_tick.pressed.connect(server.reverse_swap)
	flip.pressed.connect(func(): speed.value = -speed.value)
	tick.pressed.connect(server.sort_step)
	speed.value_changed.connect(func(v: float):
		server.tick_speed = 1 / v
	)
	resolution.value_changed.connect(func(v: float):
		server.resolution = int(v)
	)
	shuffle.pressed.connect(server.shuffle)
	sorter_type.item_selected.connect(func(idx: int):
		server.sorter = sorters.get(idx)
	)
	ignore_visup.toggled.connect(func(tog: bool):
		server.ignore_visup = tog
	)
	var zoomup := func():
		monitor.zoom = zoom.page
		monitor.scroll = zoom.value
	zoom.changed.connect(zoomup)
	zoom.value_changed.connect(zoomup.unbind(1))

func _process(delta: float) -> void:
	# control fading
	if (
		panel.get_global_rect().abs().has_point(panel.get_global_mouse_position()) or
		zoom._clk
	):
		panel.modulate.a = move_toward(panel.modulate.a, 1, delta * 2)
	else:
		panel.modulate.a = move_toward(panel.modulate.a, 0, delta * 2)
	
	# ticker
	tick_load.icon = [
		preload("uid://bu8eomdfykgyw"),
		preload("uid://bttt21ve287i7"),
		preload("uid://cpqwx030fyuca"),
		preload("uid://727mou2q30cq"),
		preload("uid://x8xm7h7fnlsr"),
		preload("uid://cj5ayod5lefly"),
		preload("uid://bhdcr4da3gi8j"),
		preload("uid://bkviwy4r23f2u"),
	][server.ticked % 8]
	ticks.text = "%4d" % server.ticked

func _up() -> void:
	# value set
	speed.value = 1 / server.tick_speed
	resolution.value = server.resolution
