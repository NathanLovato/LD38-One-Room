tool
extends Node

# Controls the main state of the game, the score, and player death
var game_state = S_START

const S_START = "start" 
const S_PLAY = "play"
const S_PAUSE = "pause"
const S_GAME_OVER = "gameover"

var viewport_size = Vector2()

# Gameplay generation
var timer_explosion = 0.0
const TIME_EXPLODE = 3.0

var max_danger_zones = 4
var difficulty = 1

# NODES
onready var player = get_node("Player")
onready var score = get_node("Score/Base")
onready var danger_container = get_node("Zones") 
onready var danger_zone = preload("res://level/Danger.tscn")

func _ready():
    viewport_size = get_viewport().get_rect().size
    set_process(true)

func _process(delta):
    if game_state == S_PLAY:
        pass
    pass

# Generates danger zones in the game
# Rectangles that appear and after some time, kill the player if he overlaps them
func create_danger_zone(position, size, timeout):
    var zone = danger_zone.instance()
    zone.set_danger_zone(position, size, TIME_EXPLODE)
    danger_container.add_child(zone)
    pass

func test_danger_zones():
    if not get_tree().is_editor_hint():
        return false
    
    create_danger_zone()
