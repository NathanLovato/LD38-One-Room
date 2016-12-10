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

var on_floor = false
var on_wall = false

const S_DEAD = 'dead'
const S_IDLE = 'idle'
const S_RUN = 'run'
const S_LAND = 'land'
const S_JUMP = 'jump'
const S_WALL_JUMP = 'walljump'
const S_FALL = 'fall'
const S_WALL = 'wall'
const S_DASH = 'dash'

const S_FLOOR = [S_IDLE, S_RUN]
const S_AIR = [S_JUMP, S_FALL]

# -------------
# MOVEMENT
# -------------
var direction = 1
var prev_direction = 1
var speed = Vector2(0.0,0.0)
var velocity = Vector2(0.0,0.0)
var gravity = 0.0
var wall_jump_direction = 0

var air_timer = 0.0
const AIR_THRESHOLD = 0.2

const MAX_SPEED = 500
const ACCELERATION_X = 2000
const ACCELERATION_X_JUMP = 3000
const FRICTION_FLOOR = 2000

# const JUMP_IMPULSE = 400
# const GRAVITY = 800
const JUMP_IMPULSE = 1200
const JUMP_IMPULSE_WALL = Vector2(400, -800)
const GRAVITY = 2600
const GRAVITY_WALL = 600
const MAX_SPEED_FALL = 800
const MAX_SPEED_FALL_WALL = 300
const MAX_SPEED_JUMP = 800
const STOP_THRESHOLD = 30

const MAX_SPEED_WALK = 800
const MAX_SPEED_RUN = 800

const MAX_SPEED_WALL_SLIDE = 200

var jump_trigger = false

func _ready():
	set_fixed_process(true)
	set_process_input(true)

	on_floor = false
	go_to_state(S_FALL)
	pass

# INPUT 
# State management based on input
func _input(event):
	jump_trigger = event.is_action_pressed("jump") and not event.is_echo()
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
		elif previous_state == S_WALL:
			on_wall = false
	if enter_state:
		enter_state = false
		if state == S_JUMP:
			on_floor = false
			speed.y = -JUMP_IMPULSE
		elif state == S_FALL:
			on_floor = false
			air_timer = 0.0
		elif state == S_WALL:
			on_wall = true
			speed.x = 0.0
			speed.y /= 1.8
		elif state == S_WALL_JUMP:
			on_wall = false
			on_floor = false
			jump_trigger = false
			speed.x = wall_jump_direction * JUMP_IMPULSE_WALL.x
			speed.y = JUMP_IMPULSE_WALL.y
	
	
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
		if not previous_state in [S_JUMP, S_WALL_JUMP] and state == S_FALL:
			air_timer += delta
			if air_timer <= AIR_THRESHOLD and jump:
				go_to_state(S_JUMP)
				# speed.y = -JUMP_IMPULSE
		elif state in [S_JUMP, S_WALL_JUMP] and speed.y > 0.0:
			go_to_state(S_FALL)
		# X MOVEMENT
		if moving:
			speed.x += ACCELERATION_X_JUMP * direction * delta
	

	# WALL MOTION
	if on_wall:
		if jump_trigger:
			go_to_state(S_WALL_JUMP)


	# GRAVITY and WALL FRICTION
	if on_wall and state == S_WALL:
		gravity = GRAVITY_WALL
	else: 
		gravity = GRAVITY
	speed.y += gravity * delta
	speed.y = clamp(speed.y, -MAX_SPEED_JUMP, MAX_SPEED_FALL)
	if speed.y > MAX_SPEED_FALL_WALL and state == S_WALL:
		speed.y = MAX_SPEED_FALL_WALL
	# APPLYING MOVEMENT
	speed.x = clamp(speed.x, -MAX_SPEED, MAX_SPEED)
	velocity.x = speed.x * delta
	velocity.y = speed.y * delta
	move(velocity)

	# COLLISIONS
	if is_colliding():
		var normal = get_collision_normal()
		
		var col_with_floor = normal == Vector2(0, -1)
		var col_with_wall = normal == Vector2(1, 0) or normal == Vector2(-1, 0)
		var col_with_ceiling = normal == Vector2(0, 1)

		# print(col_with_wall)

		if col_with_floor and not on_floor:
			go_to_state(S_IDLE)
			on_floor = true
		# print(str(on_floor) + ' / ' + str(on_wall))
		if not on_floor:
			if col_with_floor:
				go_to_state(S_IDLE)
			elif col_with_wall and state != S_WALL:
				if state != S_WALL_JUMP:
					go_to_state(S_WALL)
					wall_jump_direction = normal.x
		elif on_floor and state == S_WALL:
			go_to_state(S_IDLE)
		# if not col_with_wall and state == S_WALL:
		# 	go_to_state(S_IDLE)
		velocity = normal.slide(velocity)
		velocity = move(velocity)
	elif state in S_FLOOR:
		go_to_state(S_FALL)
	elif state == S_WALL and moving and direction == wall_jump_direction:
		go_to_state(S_FALL)
	pass

	if DEBUG_TIMER:
		print(air_timer)


func go_to_state(new_state):
	if new_state == state:
		return false
	
	previous_state = state
	state = new_state
	enter_state = true
	exit_state = true

	if DEBUG_STATE:
		print(NAME + ": " + str(state) + " // " + str(previous_state))
	pass