tool
extends Node2D
# 
# use encloses(), intersects() or has_point() to check overlap with the player

var bbox = Rect2(Vector2(100, 100), Vector2(100, 100))
var position = Vector2(100,100)
var size = Vector2(200,200)
var timeout = 0.0

# func _draw():
#     pass

func _draw():
    var color = Color(0.0, 0.0, 0.0)
    draw_zone_outline(color)

func draw_zone_outline( color ):
	var points = Vector2Array()
	points.push_back(position)
	points.push_back(Vector2(position.x + size.x, position.y))
	points.push_back(position + size)
	points.push_back(Vector2(position.x, position.y + size.y))
	points.push_back(position)

	for index in range(4):
		draw_line(points[index], points[index+1], color)


func _ready():
    init_zone(Vector2(100,100), Vector2(200,200), 3.0)
    set_process(true)
    pass

func init_zone(_position = Vector2(), _size = Vector2(), _timeout = 3.0):
    bbox = Rect2(_position, _size)
    timeout = _timeout
    if get_tree().is_editor_hint():
        update()
    set_process(true)
    pass

func _process(delta):
    if not get_tree().is_editor_hint():
        timeout -= delta
        if timeout < 0:
            queue_free()
    pass