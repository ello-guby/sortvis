@icon("uid://d228q8lra8tt1")
class_name QuickSort extends Sorter
## A sorter thats quick.
##
## @experimental: Need to do more bug check.

## Region, a split when highs on high and lows on low.
var reg := DONE
## Index on low side
var a := -1
## Index on high side
var b := -1
## Checking index
var check := 0
## Pivots to revert back when region is done and cannot be splitted more.
var pivs: Array[int] = []

func _reg(x: int, y: int) -> void:
	reg = swap(x, y)
	a = -1
	b = -1
	check = reg.x

func _data_init(d: Array[int]) -> void:
	_reg(0, d.size() - 1)
func _sort_undo(d: Array[int], _a, _b) -> void:
	_reg(0, d.size() - 1)

func _sort_step(
	data: Array[int],
	datahl: Dictionary[int, Color]
) -> Vector2i:
	var lo := reg.x
	var hi := reg.y
	var piv := data[hi]
	
	if a == -1:
		if check >= hi:
			a = hi
		if data[check] < piv:
			check += 1
		else:
			a = check
			check = hi - 1
	
	elif b == -1:
		if check <= lo:
			b = lo
		elif data[check] > piv:
			check -= 1
		else:
			b = check
	
	elif a >= b:
		if (data[a] <= piv and abs(lo - hi) <= 1) or reg.x == reg.y: # move to prev region
			if pivs:
				var x = pivs.pop_back()
				if not x: x = 0
				var y = pivs.back()
				if not y: y = data.size() - 1
				_reg(x + 1, y)
			else:
				return DONE
		else: # move to next region
			var swp := swap(a, hi)
			pivs.append(b)
			_reg(lo, b)
			return swp
	
	else: # cross swap
		var swp := swap(a, b)
		check = a + 1
		a = -1
		b = -1
		return swp
	
	# coloring
	for i in range(lo, hi + 1):
		var ndat := float(data[i]) / data.size()
		datahl[i] = Color(ndat, ndat, ndat, 1).blend(Color(1, 0, 0, 0.3))
	datahl[check] = Color.GREEN
	datahl[a] = Color.BLUE
	datahl[b] = Color.BLUE
	
	return VISUP
