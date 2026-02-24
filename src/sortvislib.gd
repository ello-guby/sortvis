class_name Lib
## An helper class.

## Return [param array] reversed.
static func reversed(array: Array) -> Array:
	var a := array.duplicate()
	a.reverse()
	return a

## Return wheather the [param array] is accendingly sorted.
static func is_sorted(array: Array[int]) -> bool:
	array = array.duplicate()
	if not array:
		return true
	var preval: int = array.pop_front()
	for i in array:
		if preval > i:
			return false
		else:
			preval = i
	return true

## Probe scripts extending [Sorter]
static func probe_sorters() -> Array[Sorter]:
	var sorters: Array[Sorter] = []
	var dacc := DirAccess.open("res://")
	_probe_sorters(dacc, sorters)
	return sorters

static func _probe_sorters(dacc: DirAccess, sorters: Array[Sorter]) -> void:
	for f in dacc.get_files():
		if not f.get_extension() == "gd": continue
		var s := load(dacc.get_current_dir().path_join(f))
		if s is GDScript:
			# just search if file has class_name, extends Sorter and implement _sort_step
			var re := RegEx.create_from_string( 
				r"^[\s\S]*?(class_name\s+(.*?)\s+extends\s+Sorter\s[\s\S]*?func\s+_sort_step)[\s\S]*?$"
			)
			if re.search(s.source_code):
					sorters.append(s.new() as Sorter)
	for d in dacc.get_directories():
		dacc.change_dir(d)
		_probe_sorters(dacc, sorters)
	dacc.change_dir("..")
