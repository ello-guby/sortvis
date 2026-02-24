class_name SortServerDataMonitor extends Control
## A control displaying [member SortServer.data].

## The [SortServer] to display the data.
@export var server: SortServer

## Zoom level.
@export var zoom := 1.0
## Scroll.
@export var scroll := 0.0

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not server: return
	var data := server.data
	var dsize := data.size()
	var spacing := size / dsize
	for i in range(dsize):
		var nval := float(data[i]) / dsize
		var height := size.y * nval
		var pos := Rect2(Vector2(
			((spacing.x * i) / zoom) - (scroll * (spacing.x / zoom) * dsize),
			size.y
		), Vector2(
			(spacing.x / zoom),
			-height
		))
		var col: Color = server.data_highlight.get(i,
			Color(nval, nval, nval, 1.0)
		)
		draw_rect(pos, col)
