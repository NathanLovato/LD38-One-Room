extends Node2D

const DEBUG_STATE = false
const DEBUG_INPUT = false
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
var acceleration = Vector2()
var velocity = Vector2()
var max_speed = Vector2()

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
	
	pass

# INPUT 
# State management based on input
func _input(event):
	var test = event.is_action_pressed()
	
	var move_left = test("move_left")
	var move_right = test("move_right")
	var jump = test("jump")
	var duck = test("duck")
	
	if event.is_echo():
		if state == S_IDLE and move_left or move_right:
			go_to_state(S_RUN)

		if move_left:
			direction = -1
		elif move_right:
			direction = 1
	pass

func _process(delta):
	if exit_state:
		exit_state = false
	
	if enter_state:
		enter_state = false
	
	# MOVEMENT
	if state == S_RUN:
		speed.x += acceleration * delta
		speed.x = clamp(speed, 0, max_speed)
		pass
	
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