extends KinematicBody2D

const DEBUG_STATE = true
const DEBUG_INPUT = false
const DEBUG_TIMER = false
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
const S_WALL = 5
const S_DASH = 6

const S_FLOOR = [S_IDLE, S_RUN]
const S_AIR = [S_JUMP, S_FALL]

# -------------
# MOVEMENT
# -------------
var direction = 1
var prev_direction = 1
var speed = Vector2(0.0,0.0)
var velocity = Vector2(0.0,0.0)

var air_timer = 0.0
const AIR_THRESHOLD = 0.2

const MAX_SPEED = 500
const ACCELERATION_X = 2000
const ACCELERATION_X_JUMP = 3000
const FRICTION_FLOOR = 2000

const JUMP_IMPULSE = 1200
const GRAVITY = 2600
const FRICTION_WALL = 600
const MAX_SPEED_FALL = 800
const MAX_SPEED_JUMP = 800
const STOP_THRESHOLD = 30

const MAX_SPEED_WALK = 800
const MAX_SPEED_RUN = 800

const MAX_SPEED_WALL_SLIDE = 200

var on_floor = false
var on_wall = false

func _ready():
	set_fixed_process(true)
	set_process_input(true)

	on_floor = false
	go_to_state(S_FALL)
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
		if previous_state == S_RUN and state == S_IDLE:
			speed.x /= 4
		elif previous_state == S_FALL and state in S_FLOOR:
			on_floor = true
			on_wall = false
			speed.x /= 2
			speed.y = 0.0
	if enter_state:
		enter_state = false
		if state == S_JUMP:
			on_floor = false
			speed.y = -JUMP_IMPULSE
		elif state == S_FALL:
			on_floor = false
			air_timer = 0.0
	
	
	# MOVEMENT HORIZONTAL ON FLOOR
	# FIXME: Movement lag with Joystick
	prev_direction = direction
	if move_right: 
		direction = 1
	elif move_left: 
		direction = -1
	
	if on_floor:
		speed.y = 0.0
		# STATES
		if jump:
			go_to_state(S_JUMP)
		elif moving:
			if state == S_IDLE:
				go_to_state(S_RUN)
		elif state == S_RUN:
			go_to_state(S_IDLE)
		
		# SPEED X
		speed.x = abs(speed.x)

		if direction != prev_direction:
			speed.x /= 2
		
		if state == S_RUN:
			speed.x += ACCELERATION_X * delta
		elif state == S_IDLE:
			if speed.x > STOP_THRESHOLD:
				speed.x -= FRICTION_FLOOR * delta
			else:
				speed.x = 0
		
		speed.x *= direction
	# AIR MOTION
	elif not on_floor:
		if previous_state != S_JUMP and state == S_FALL:
			air_timer += delta
			if air_timer <= AIR_THRESHOLD and jump:
				go_to_state(S_JUMP)
				# speed.y = -JUMP_IMPULSE
		elif state == S_JUMP and speed.y > 0.0:
			go_to_state(S_FALL)
		# X MOVEMENT
		if moving:
			speed.x += ACCELERATION_X_JUMP * direction * delta
	
	speed.y += GRAVITY * delta
	speed.y = clamp(speed.y, -MAX_SPEED_JUMP, MAX_SPEED_FALL)

	
	# APPLYING MOVEMENT
	speed.x = clamp(speed.x, -MAX_SPEED, MAX_SPEED)
	velocity.x = speed.x * delta
	velocity.y = speed.y * delta
	move(velocity)

	# COLLISIONS
	if is_colliding():
		var normal = get_collision_normal()
		var collision_with_floor = normal == Vector2(0, -1)

		if not on_floor and collision_with_floor:
			go_to_state(S_IDLE)
		
		velocity = normal.slide(velocity)
		velocity = move(velocity)
	elif state in S_FLOOR:
		go_to_state(S_FALL)
	pass

	if DEBUG_TIMER:
		print(air_timer)


func go_to_state(new_state):
	if new_state != state:
		previous_state = state
	state = new_state
	enter_state = true
	exit_state = true

	if DEBUG_STATE:
		print(NAME + " state: " + str(state) + " // previous: " + str(previous_state))
	pass