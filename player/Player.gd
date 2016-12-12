# Here is the code that controls the player.
# These are just some basic platforming mechanics like running jumping, wall jumps, and the ability to cancel falls (You have 0.2 seconds to jump when you are falling to come back safely on your platform).

# Wall detection is not super tight right now:
# I tried to work exclusively with a simple box collider at first, being used to that and some other engines, and it is not sufficient here.
# There is some really quick ray casts added at the last minutes to try and fix some of the issues, But there are still cases where you my wall next to a wall and the character will not stick to it.
extends KinematicBody2D

const DEBUG_STATE = true
const DEBUG_INPUT = false
const DEBUG_TIMER = false
const NAME = 'Player'

var skin 

# -------------
# STATE MACHINE
# -------------
# These variables control the states of the player.The states have 2 purposes: for one, they help us to develop a mental model of what the character is doing
# For me, if I can think "Oh, the character is in the jump state", I know that afterwards he will either fall, land on a wall or on the ground. 
# So there are 3 states he can flow into from S_JUMP, which means that there are virtually 3 places in the code that might get buggy when I start to add new features.
var state = S_FALL
var previous_state = S_IDLE
var enter_state = false
var exit_state = false

var on_floor = false
var on_wall = false

# I use constants to store the states, for code completion. 
# The "S_" prefix makes it very easy to find them. Just type "S_" and you get a list of all of the available states, and no other variables! 
const S_DEAD = 'dead'
const S_IDLE = 'idle'
const S_RUN = 'run'
const S_JUMP = 'jump'
const S_WALL_JUMP = 'walljump'
const S_FALL = 'fall'
const S_WALL = 'wall'
const S_LAND = 'land' # Unused, mainly useful for animation

# Sometimes I will use an array of states, in conditions, with the "in" keyword: "if state in [STATE1, STATE2, STATE3, ...]" 
const S_FLOOR = [S_IDLE, S_RUN]
const S_AIR = [S_JUMP, S_FALL]

# -------------
# MOVEMENT
# -------------
var direction = 1
var prev_direction = 1

# I first use this speed vector to get absolute X and Y speed values,
# Then it gets multiplied by the player movement direction and delta time to get the actual movement
var speed = Vector2(0.0,0.0)
var velocity = Vector2(0.0,0.0)
var gravity = 0.0 # Curent gravity applied to the player (lower when he is on a wall, to account for friction)

# These 2 values allow you to jump when you start falling
var air_timer = 0.0
const AIR_THRESHOLD = 0.2

# The constants below should be self-explanatory:
const MAX_SPEED = 500
const ACCELERATION_X = 2000
const ACCELERATION_X_JUMP = 3000
const FRICTION_FLOOR = 2000
const STOP_THRESHOLD = 30

const JUMP_IMPULSE = 700
const JUMP_IMPULSE_WALL = Vector2(400, -800)
const GRAVITY = 2600
const GRAVITY_WALL = 500
const MAX_SPEED_FALL = 800
const MAX_SPEED_FALL_WALL = 300
const MAX_SPEED_JUMP = 900
const MAX_SPEED_WALL_SLIDE = 200

# Stores the 2 rays that are used exclusively for wall detection - See the player.tscn scene
var rays = []
var wall_jump_direction = 0

# Boolean used for input only
var jump = false


func _ready():
	set_fixed_process(true)
	set_process_input(true)

	skin = get_node("Sprite")

	rays.append(get_node("Raycast_R"))
	rays.append(get_node("Raycast_L"))

	on_floor = false
	go_to_state(S_FALL)


func _input(event):
	# The input function is only called when there is an input. And the is action pressed method should only return true when you start pressing the button.
	# Then, when the button is released, we reset the jump variable to false so that the player doesn' t jump automatically.
	jump = event.is_action_pressed("jump") and not event.is_echo()
	if event.is_action_released("jump"):
		jump = false


func _fixed_process(delta):
	# INPUT
	var move_left = Input.is_action_pressed("move_left")
	var move_right = Input.is_action_pressed("move_right")
	var moving = move_left or move_right

	var duck = Input.is_action_pressed("duck")
	
	# MOVEMENT HORIZONTAL ON FLOOR
	prev_direction = direction
	if move_right: 
		direction = 1
		skin.flip_h = false
	elif move_left: 
		direction = -1
		skin.flip_h = true
	
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
		elif state in [S_JUMP, S_WALL_JUMP] and speed.y > 0.0:
			go_to_state(S_FALL)
		# X MOVEMENT
		if moving:
			speed.x += ACCELERATION_X_JUMP * direction * delta
	

	# WALL MOTION
	if on_wall:
		if jump:
			go_to_state(S_WALL_JUMP)


	# GRAVITY and WALL FRICTION
	if on_wall:
		gravity = GRAVITY_WALL
	else: 
		gravity = GRAVITY
	speed.y += gravity * delta
	speed.y = clamp(speed.y, -MAX_SPEED_JUMP, MAX_SPEED_FALL)

	if speed.y > MAX_SPEED_FALL_WALL and state == S_WALL:
		speed.y = MAX_SPEED_FALL_WALL
	# APPLYING MOVEMENT and moving the character
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

		if col_with_ceiling and speed.y < 0:
			speed.y = 0

		if col_with_floor and not on_floor:
			go_to_state(S_IDLE)
			on_floor = true
		
		if not on_floor:
			if col_with_floor:
				go_to_state(S_IDLE)
			elif col_with_wall and state != S_WALL:
				if state != S_WALL_JUMP:
					go_to_state(S_WALL)
					wall_jump_direction = normal.x
		
		elif on_floor and state == S_WALL:
			go_to_state(S_IDLE)
		
		velocity = normal.slide(velocity)
		velocity = move(velocity)
	elif state in S_FLOOR:
		go_to_state(S_FALL)
	elif state in [S_WALL, S_JUMP, S_FALL, S_WALL_JUMP]:
		var next_to_wall = false
		for ray in rays:
			if ray.get_collider():
				next_to_wall = true
		if not next_to_wall and state == S_WALL:
			go_to_state(S_FALL)


func go_to_state(new_state):
	# A simple function for state management. It ensures that the new state is different from the current one and then updates the corresponding variable.
	# It calls back enter_new_state() every time.
	if new_state == state:
		return false
	
	previous_state = state
	state = new_state
	enter_new_state()

	if DEBUG_STATE:
		print(NAME + ": " + str(state) + " // " + str(previous_state))


func enter_new_state():
	# Called every time the character enters a new state.
	# The first part of the block looks at the last state the player was in and changes some values based on that, and the 2nd block corresponds to actually entering the new state.
	# This is not absolutely required, but this helps me to think about how my states flow into one another.
	# EXIT STATE
	if previous_state == S_RUN and state == S_IDLE:
		speed.x /= 4
	elif previous_state == S_FALL and state in S_FLOOR:
		on_floor = true
		on_wall = false
		speed.x /= 2
		speed.y = 0.0
	elif previous_state == S_WALL:
		on_wall = false
	# ENTER STATE
	if state == S_JUMP:
		on_floor = false
		speed.y = -JUMP_IMPULSE
	elif state == S_FALL:
		on_floor = false
		air_timer = 0.0
		if previous_state == S_WALL:
			speed.x = 0.0
	elif state == S_WALL:
		on_wall = true
		speed.x = 0.0
		speed.y /= 1.8
	elif state == S_WALL_JUMP:
		on_wall = false
		on_floor = false
		speed.x = wall_jump_direction * JUMP_IMPULSE_WALL.x
		speed.y = JUMP_IMPULSE_WALL.y
	