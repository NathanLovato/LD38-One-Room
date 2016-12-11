extends Node

# Controls the main state of the game, the score, and player death
var game_state = S_START

const S_START = "start" 
const S_PLAY = "play"
const S_PAUSE = "pause"
const S_GAME_OVER = "gameover"


# Gameplay generation
var timer_explosion = 0.0
const TIME_EXPLODE = 3.0


var max_danger_zones = 4
var difficulty = 1

# NODES
onready var player = get_node("Player")
onready var score = get_node("Score/Base")
var danger_zone = preload("res://myscene.scn")

func _ready():
    set_process(true)

    pass

func _process(delta):
    if game_state == S_PLAY:
        pass
    pass

# Generates danger zones in the game
# Rectangles that appear and after some time, kill the player if he overlaps them
func create_danger_zone():

    pass
