class_name SortServer extends Node
## A server to store sorting data.

## Emitted after resolution is changed.
signal resolution_changed(new_resolution: int)

## The sorter.
@export var sorter: Sorter:
	set(v):
		sorter = v
		redata()
		if sorter:
			sorter._data_init(data.duplicate())
## List of sorters. if empty on ready, populate with [method Lib.probe_sorters].
@export var sorters: Array[Sorter] = []
## The size of the data
@export var resolution: int = 10:
	set(v): resolution = v; redata(); resolution_changed.emit(v)
## Time it take to do another sort step
@export var tick_speed: float = 1.0:
	set(v): tick_speed = v; _t = abs(tick_speed)
## If [code]true[/code], skip step that return [constant Sorter.VISUP],
## fast forward to step that reutrn swap.
@export var ignore_visup: bool = false
## Wheather is paused
@export var paused: bool = true:
	set(v): paused = v; _t = abs(tick_speed)
## How many times it ticked from [method shuffle]
var ticked: int = 0
## At which index the pop occur.
var pop_idx: int = 0
## At which index the push occur.
var push_idx: int = 0
## Wheather the sorting is done/finished.
var done: bool = false
## Swap history. Clear on [method shuffle]
var swap_history: Array[Vector2i] = []
## The data array
var data: Array[int] = []
## Data index highlight, as [code]dict[idx, color][/code].
var data_highlight: Dictionary[int, Color] = {}

var _t := 0.0 # time

func _ready() -> void:
	if not sorters:
		sorters = Lib.probe_sorters()
	
	redata()

## Reload data to the size of [member resolution]
func redata() -> void:
	swap_history.clear()
	data_highlight.clear()
	
	data.clear()
	for i in range(resolution):
		data.append(i + 1)
	
	ticked = 0
	done = false
	_t = abs(tick_speed)

func _process(delta: float) -> void:
	if not paused:
		_t -= delta
	
	if tick_speed >= 0:
		while _t <= 0:
			_t += abs(tick_speed)
			if sort_step() == Sorter.VISUP and ignore_visup:
				_t -= abs(tick_speed)
	else:
		while _t <= 0:
			_t += abs(tick_speed)
			reverse_swap()

## Sort [member data] by one step. Return the swapped.
func sort_step() -> Vector2i:
	if sorter and not done:
		data_highlight.clear()
		var swp := sorter._sort_step(data.duplicate(), data_highlight)
		match swp:
			Sorter.DONE:
				done = true
				sorter._data_done(data.duplicate(), data_highlight)
			Sorter.VISUP:
				if not ignore_visup:
					ticked += 1
			_:
				swap(swp.x, swp.y)
		return swp
	return Sorter.DONE

## Swap [member data] at index [param a] and [param b].
func swap(a: int, b: int) -> void:
	incognito_swap(a, b)
	pop_idx = a
	push_idx = b
	swap_history.append(Vector2i(a, b))
	ticked += 1

## [method swap] without storing into [member swap_history].
func incognito_swap(a: int, b: int) -> void:
	var n := data[a]
	data[a] = data[b]
	data[b] = n

## Undo a [method swap].
func reverse_swap() -> void:
	data_highlight.clear()
	if swap_history:
		var s: Vector2i = swap_history.pop_back()
		incognito_swap(s.x, s.y)
		pop_idx = s.x
		push_idx = s.y
		data_highlight.set(s.x, Color.RED)
		data_highlight.set(s.y, Color.RED)
		ticked -= 1
		done = false
		sorter._sort_undo(data.duplicate(), s.x, s.y)

## Shuffle [member data].
func shuffle() -> void:
	redata()
	data.shuffle()
	if sorter: sorter._data_init(data.duplicate())

## Change [member sorter] with a sorter matching [param idx_or_name] in [member sorters].
## Return successness.
func change_sorter(idx_or_name: Variant) -> bool:
	var s: Sorter = null
	match typeof(idx_or_name):
		TYPE_INT:
			s = sorters.get(idx_or_name)
		TYPE_STRING:
			for sort in sorters:
				var src = sort.get_script()
				if src is Script:
					if src.get_global_name().similarity(idx_or_name) > 0.5:
						s = sort
						break
	if s:
		sorter = s
		return true
	return false
