tool
extends Node

var game_state = S_START
var game_state_id = 0

const S_START = "start" 
const S_NEW_ROUND = "play"
const S_DANGER = "danger"
const S_EXPLODE = "explode"
const S_WAIT = "wait"
const S_GAME_OVER = "gameover"

const GAME_STATE_FLOW = [S_NEW_ROUND, S_DANGER, S_EXPLODE, S_WAIT] 

var viewport_size = Vector2()
var danger_size = Vector2()

# Gameplay generation
var timer = 0.0
const TIME_EXPLODE = 3.0
const TIME_WAIT = 2.0

var difficulty = 1
const MAX_DANGER_ZONES = 3
const DANGER_ZONE_COUNT = 4
var max_index = DANGER_ZONE_COUNT - 1

# NODES
onready var player = get_node("Player")
onready var score = get_node("Score/Base")
onready var danger_zone = preload("res://level/Danger.tscn")
onready var danger_container = get_node("Zones") 

var all_danger_zones


func _ready():
    viewport_size = get_viewport().get_rect().size
    danger_size = viewport_size / 2

    var DANGER_SPAWN = [Vector2(), Vector2(danger_size.x, 0), Vector2(0, danger_size.y), Vector2(danger_size)]    

    for i in range(DANGER_ZONE_COUNT):
        var zone = danger_zone.instance()
        danger_container.add_child(zone)
        zone.initialize(DANGER_SPAWN[i], danger_size)

    all_danger_zones = danger_container.get_children()

    game_state = S_NEW_ROUND
    set_process(true)


func _process(delta):
    if game_state == S_NEW_ROUND:
        var number = randi() % MAX_DANGER_ZONES
        if number <= 0:
            number = 1

        activate_danger_zones(number)
        go_to_next_state()
    elif game_state == S_DANGER:
        timer -= delta
        if timer < 0:
            go_to_next_state()
    elif game_state == S_EXPLODE:
        print('BOOM')
        go_to_next_state()
        # check if player in danger zone
        # if so game over
        # else add score and go back to play
        pass
    elif game_state == S_WAIT:
        timer -= delta
        if timer < 0:
            go_to_next_state()
        pass
    pass


# Activates x of the DANGER_ZONE_COUNT danger zones
func activate_danger_zones(number):
    # var zones_to_activate = []
    var used_indexes = []
    var start_index = randi() % max_index

    for i in range(number):
        var index = (i + start_index) % max_index
        all_danger_zones[index].activate(TIME_EXPLODE)


func test_danger_zones():
    if not get_tree().is_editor_hint():
        return false

    create_danger_zone()


func go_to_next_state():
    game_state_id += 1
    if game_state_id > GAME_STATE_FLOW.size() - 1:
        game_state_id = 0
    
    game_state = GAME_STATE_FLOW[game_state_id]

    if game_state == S_DANGER:
        timer = TIME_EXPLODE
    elif game_state == S_WAIT:
        timer = TIME_WAIT