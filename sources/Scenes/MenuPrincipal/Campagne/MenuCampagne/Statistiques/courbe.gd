extends Control

var monthly_minutes := [120, 90, 150, 200, 180, 220]

func _draw():
	if monthly_minutes.is_empty():
		return

	var max_val = monthly_minutes.max()
	var step_x = size.x / (monthly_minutes.size() - 1)

	var points = []
	for i in range(monthly_minutes.size()):
		var x = i * step_x
		var y = size.y - (monthly_minutes[i] / max_val) * size.y
		points.append(Vector2(x, y))

	draw_polyline(points, Color(0.3, 0.6, 1.0), 3)
