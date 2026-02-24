@icon("res://share/icons/Sorter.svg")
@abstract class_name Sorter extends Resource
## A sorter used by server to sort data.

## A done return, Return this if the sorting is done.
const DONE = -Vector2i.ONE
## A visual update return, Return this if you just want to update highlight.
const VISUP = -Vector2i.ONE * 2

@warning_ignore("unused_parameter")
## Virtual method called after [member SortServer.data] got initiated/shuffled.
## Comes with a copy of the data.
func _data_init(data: Array[int]) -> void:
	pass

## Virtual method to sort by a step.
## Comes with a copy of [member Server.data] to find swaping index,
## and overwritable [member Server.data_highlight] to highlight data.[br][br]
## 
## Returns shall be [code]Vector2i(index1, index2)[/code],
## work like swap. Use [method swap] to idiomaticly
## create [Vector2i] returnal.
## Return [constant DONE] if sorting finished.
@abstract func _sort_step(
	data: Array[int],
	data_highlight: Dictionary[int, Color]
) -> Vector2i

@warning_ignore("unused_parameter")
## Virtual method called after [method SortServer.reverse_swap] is called.
## Comes with a copy of the [member SortServer.data] and the undoes swap index.
func _sort_undo(data: Array[int], a: int, b: int) -> void:
	pass

@warning_ignore("unused_parameter")
## Virtual method called once after [method _sort_step] return [const DONE].
## Comes with a copy of the [member SortServer.data] and overwritable
## [member Server.data_highlight] to highlight data.
func _data_done(
	data: Array[int],
	data_highlight: Dictionary[int, Color]
) -> void:
	pass

## Idiomaticly create [Vector2i] for [method _sort_step] returnal.
static func swap(a: int = 0, b: int = 0) -> Vector2i:
	return Vector2i(a, b)
