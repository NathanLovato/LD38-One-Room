tool
extends Node2D

# Testing out drawing in the editor - should be replaced by Area2d or another builtin collider
# Rect2.has_point(player.get_pos()) to detect collisions with the player
var bbox = Rect2() #bounding box, used for drawing and collisions
var color = Color(0.6, 0.1, 0.0)

const OPACITY_ACTIVE = 0.3


func _draw():
    # Draws the box's outline in the editor or fills a rectangle in-game
    if get_tree().is_editor_hint():
        draw_zone_outline(color)
    else:
        draw_rect(bbox, color)


func draw_zone_outline( color ):
    # Defines the 4 vertices of the rectangle and draws the 4 lines connecting them
	var points = Vector2Array()

	points.push_back(Vector2())
	points.push_back(Vector2(bbox.end.x, 0))
	points.push_back(bbox.end)
	points.push_back(Vector2(0, bbox.end.y))
    # Adding the first vertex a second time to be able to loop over the array
	points.push_back(Vector2())

	for index in range(4):
		draw_line(points[index], points[index+1], color)


func _ready():
    set_opacity(0.0)
    update()


func initialize(_position = Vector2(), _size = Vector2()):
    # Intializes the bbox variable. The danger zone is a Node2d, so it uses its own position for placement
    set_pos(_position)
    bbox = Rect2(Vector2(), _size)
    
    if get_tree().is_editor_hint():
        color = Color(0.0, 0.0, 0.0)


func activate():
    set_opacity(OPACITY_ACTIVE)


func deactivate():
    set_opacity(0)
