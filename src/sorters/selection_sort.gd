class_name SelectionSort extends Sorter
## Sorter that find the smallest and put it below.

## Sorted index, from 0.
var doned := -1
## Checking index.
var check := 0
## Index where minimum lies.
var minidx := 0

func _data_init(_data) -> void:
	doned = -1
	check = 0
	minidx = 0
func _sort_undo(_data, _a, _b) -> void:
	doned = -1
	check = 0
	minidx = 0

func _sort_step(
	data: Array[int],
	data_highlight: Dictionary[int, Color]
) -> Vector2i:
	if doned >= data.size() - 1:
		return DONE
	
	if data[check] <= data[minidx]:
		minidx = check
	
	data_highlight[minidx] = Color.DARK_GREEN
	data_highlight[check] = Color.GREEN
	
	if check < data.size():
		check += 1
		
		if check >= data.size():
			data_highlight[doned + 1] = Color.BLUE
			data_highlight[minidx] = Color.BLUE
			
			var swp := swap(doned + 1, minidx)
			doned += 1
			check = doned + 1
			minidx = doned + 1
			
			
			return swp
	
	return VISUP
