class_name UIV3
extends RefCounted

const NAVY := Color("0a274d")
const CREAM := Color("fff8ed")
const CREAM_SOFT := Color("f9ead7")
const CREAM_PANEL := Color("fcedda")
const CREAM_BORDER := Color("edc9a5")
const CORAL := Color("f04d3c")
const CAMPAIGN := Color("e52b1f")
const LEVEL := Color("119d9c")
const PLATEAU := Color("7137a8")
const MODE := Color("d98219")
const BODY := Color("121921")

static func box(color: Color, radius := 16, border := Color.TRANSPARENT, width := 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_color = border
	style.border_width_left = width
	style.border_width_top = width
	style.border_width_right = width
	style.border_width_bottom = width
	return style

static func place(control: Control, rect: Rect2) -> Control:
	control.position = rect.position
	control.size = rect.size
	return control


