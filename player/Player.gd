extends KinematicBody2D

const DEBUG_STATE = true
const DEBUG_INPUT = true
const NAME = 'Player'

# -------------
# STATE MACHINE
# -------------
var state = S_IDLE
var previous_state = S_IDLE
var enter_state = false
var exit_state = false

const S_DEAD = -1
const S_IDLE = 0
const S_RUN = 1
const S_JUMP = 2
const S_FALL = 3
const S_LAND = 4
const S_WALL = 5
const S_DASH = 6

# -------------
# MOVEMENT
# -------------
var direction = 1
var speed = Vector2()
var velocity = Vector2()

const MAX_SPEED = 800
const ACCELERATION_X = 1500
const DECCELERATION_X = 1800
const SQRT_2 = Vector2(sqrt(2), sqrt(2))

const JUMP_POWER = 800
const GRAVITY = 800
const MAX_SPEED_FALL = 800

const MAX_SPEED_WALK = 800
const MAX_SPEED_RUN = 800

const MAX_SPEED_WALL_SLIDE = 200

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	pass

# INPUT 
# State management based on input
func _input(event):
	var is_moving_left = event.is_action("move_left")
	var is_moving_right = event.is_action("move_right")
	var start_move_left = event.is_action_pressed("move_left")
	var start_move_right = event.is_action_pressed("move_right")

	var is_moving = is_moving_left or is_moving_right or start_move_left or start_move_right
	
	var jump = event.is_action_pressed("jump")
	var duck = event.is_action_pressed("duck")
	
	if DEBUG_INPUT and start_move_left or start_move_right or jump or duck:
		print(event)

	if state == S_IDLE and start_move_left or start_move_right:
		go_to_state(S_RUN)
	if state == S_RUN and not is_moving:
		go_to_state(S_IDLE)

	if start_move_left:
		direction = -1
	elif start_move_right:
		direction = 1
	pass

func _fixed_process(delta):
	if exit_state:
		exit_state = false
	
	if enter_state:
		enter_state = false
	
	# MOVEMENT
	if state == S_RUN:
		speed.x += ACCELERATION_X * delta
		speed.x = clamp(speed.x, 0, MAX_SPEED)
	elif state == S_IDLE:
		speed.x -= ACCELERATION_X * delta
		speed.x = clamp(speed.x, 0, MAX_SPEED)

	velocity = speed * direction * delta
	move(velocity)

	var slide_attempts = 4
	while(is_colliding() and slide_attempts > 0):
		velocity = get_collision_normal().slide(velocity)
		velocity = move(velocity)
		slide_attempts -= 1
	pass

func go_to_state(new_state):
	if new_state != state:
		previous_state = state
	state = new_state
	enter_state = true
	exit_state = true

	if DEBUG_STATE:
		print(NAME + " state: " + str(state) + " // previous: " + str(previous_state))
	pass