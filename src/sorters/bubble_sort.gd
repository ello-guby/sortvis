@icon("res://share/icons/Bubble.svg")
class_name BubbleSort extends Sorter
## A sorter that sort sweeply.

## Checking at index.
var checking := 0
## Have swapped on this round?
var swapped := false

func _data_init(_data: Array[int]) -> void:
	checking = 0
	swapped = false
func _sort_undo(_data: Array[int], _a: int, _b: int) -> void:
	checking = 0
	swapped = false

func _sort_step(
	data: Array[int],
	data_highlight: Dictionary[int, Color]
) -> Vector2i:
	if checking < data.size() - 2:
		checking += 1
	else:
		if swapped == false:
			return DONE
		checking = 0
		swapped = false
	data_highlight[checking] = Color.GREEN
	data_highlight[checking + 1] = Color.GREEN
	if data[checking] > data[checking + 1]:
		data_highlight[checking] = Color.BLUE
		data_highlight[checking + 1] = Color.BLUE
		swapped = true
		return swap(checking, checking + 1)
	return VISUP
