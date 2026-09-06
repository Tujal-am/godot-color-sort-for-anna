extends Control

var wins := 10
var losses := 4

func _draw():
	var total = wins + losses
	if total == 0:
		return

	var bar_width = size.x / 2 - 10

	# Victoires
	var h1 = floori((1. * wins / total) * size.y)
	draw_rect(Rect2(0, size.y - h1, bar_width, h1), Color(0.2, 0.8, 0.3))

	# Défaites
	var h2 = floori((1. * losses / total) * size.y)
	draw_rect(Rect2(bar_width + 20, size.y - h2, bar_width, h2), Color(0.9, 0.3, 0.3))
