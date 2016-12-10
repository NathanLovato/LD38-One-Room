extends KinematicBody2D

const DEBUG_STATE = false
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
const S_LAND = 4
const S_JUMP = 2
const S_FALL = 3
const  = 5
const S_DASH = 6

# -------------
# MOVEMENT
# -------------
var direction = 1
var prev_direction = 1
var speed = Vector2(0.0,0.0)
var velocity = Vector2(0.0,0.0)

const MAX_SPEED = 800
const ACCELERATION_X = 1500
const DECCELERATION_X = 3000
const SQRT_2 = Vector2(sqrt(2), sqrt(2))

const JUMP_POWER = 800
const GRAVITY = 800
const FRICTION_FLOOR = 800
const FRICTION_WALL = 600
const MAX_SPEED_FALL = 800

const MAX_SPEED_WALK = 800
const MAX_SPEED_RUN = 800

const MAX_SPEED_WALL_SLIDE = 200

var on_floor = true
var on_wall = false

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	pass

# INPUT 
# State management based on input
func _input(event):
	pass

func _fixed_process(delta):
	# INPUT
	var move_left = Input.is_action_pressed("move_left")
	var move_right = Input.is_action_pressed("move_right")
	var moving = move_left or move_right

	var jump = Input.is_action_pressed("jump")
	var duck = Input.is_action_pressed("duck")

	# ENTER AND EXIT STATE
	if exit_state:
		exit_state = false
		if previous_state == S_RUN:
			speed.x /= 4
	if enter_state:
		enter_state = false
	
	
	# MOVEMENT HORIZONTAL
	# FIXME: Movement lag with Joystick
	prev_direction = direction
	if move_right: 
		direction = 1
	elif move_left: 
		direction = -1
	
	if on_floor:
		if jump:
			go_to_state(S_JUMP)
		elif moving:
			if state == S_IDLE:
				go_to_state(S_RUN)
		elif state == S_RUN:
			go_to_state(S_IDLE)
		if direction != prev_direction:
			speed.x /= 2
	
	if state == S_RUN:
		speed.x += ACCELERATION_X * delta
	elif state == S_IDLE:
		speed.x -= DECCELERATION_X * delta
	
	speed.x = clamp(speed.x, 0, MAX_SPEED)


	# AIR MOTION
	if not on_floor and not on_wall:
		speed.y += GRAVITY * delta
	if state == S_JUMP:

	
	# APPLYING MOVEMENT
	velocity = speed * direction * delta
	move(velocity)

	if is_colliding():
		velocity = get_collision_normal().slide(velocity)
		velocity = move(velocity)
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