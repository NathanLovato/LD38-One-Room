tool
extends Node2D

# Testing out drawing in the editor - could be replaced by Area2d or another collider
# Use encloses(), intersects() or has_point() to check overlap with the player
var bbox = Rect2()
var timeout = 0.0
var color = Color(0.4, 0.5, 0.0)

const ACTIVE_OPACITY = 0.3
var target_opacity = 0.0

func _draw():
    if get_tree().is_editor_hint():
        draw_zone_outline(color)
    else:
        draw_rect(bbox, color)


func draw_zone_outline( color ):
	var points = Vector2Array()

	points.push_back(Vector2())
	points.push_back(Vector2(bbox.end.x, 0))
	points.push_back(bbox.end)
	points.push_back(Vector2(0, bbox.end.y))
	points.push_back(Vector2())

	for index in range(4):
		draw_line(points[index], points[index+1], color)


func initialize(_position = Vector2(), _size = Vector2()):
    set_pos(_position)
    bbox = Rect2(Vector2(), _size)
    
    if get_tree().is_editor_hint():
        color = Color(0.0, 0.0, 0.0)

func _ready():
    set_opacity(0.0)
    update()


func activate():
    # timeout = _timeout
    set_process(true)
    set_opacity(ACTIVE_OPACITY)

func deactivate():
    set_process(false)
    set_opacity(0)


# func _process(delta):
#     pass
