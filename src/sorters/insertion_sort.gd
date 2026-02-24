class_name InsertionSort extends Sorter
## A sorter that take index and find it place.

## Which index has been sorted.
var doned := 0
## Which index is take to be moved.
var moving := 1

func _data_init(_data: Array[int]) -> void:
	doned = 0
	moving = 1
func _sort_undo(_data: Array[int], _a: int, _b: int) -> void:
	doned = 0
	moving = 1

func _sort_step(
	data: Array[int],
	data_highlight: Dictionary[int, Color]
) -> Vector2i:
	if doned >= data.size() - 1:
		return DONE
	
	data_highlight[moving] = Color.GREEN
	data_highlight[moving - 1] = Color.GREEN
	
	if moving == 0:
		doned += 1
		moving = doned + 1
	
	if data[moving] < data[moving - 1]:
		data_highlight[moving] = Color.BLUE
		data_highlight[moving - 1] = Color.BLUE
		var r := swap(moving, moving - 1)
		moving -= 1
		return r
	
	else:
		doned += 1
		moving = doned + 1
	return VISUP
