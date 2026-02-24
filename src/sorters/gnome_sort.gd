class_name GnomeSort extends Sorter
## Sorter that pickup gnome (min) and put it straight to his spot.

var check := 1

func _data_init(_data) -> void:
	check = 1
func _sort_undo(_data, _a, _b) -> void:
	check = 1

func _sort_step(
	data: Array[int],
	datahl: Dictionary[int, Color]
) -> Vector2i:
	if check >= data.size():
		return DONE
	
	if check <= 0:
		check = 1
	
	if data[check - 1] > data[check]:
		datahl[check - 1] = Color.BLUE
		datahl[check] = Color.BLUE
		
		var swp := swap(check - 1, check)
		check -= 1
		
		return swp
	
	else:
		datahl[check] = Color.GREEN
		check += 1
	
	return VISUP
