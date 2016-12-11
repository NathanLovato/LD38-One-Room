extends Node2D

# STATES
var state = S_IDLE
var previous_state = S_IDLE
var enter_state = false
var exit_state = false

const S_IDLE = 0
const S_TIMER = 1
const S_ANIMATE = 2

# SCORE
var score = 0
var timer = 0.0

const TIMER_FADEOUT = 1.0
const TARGET_OPACITY = 0.7
const OPACITY_ANIM_RATE = 0.8

# NODES
var text


func _ready():
	set_process(true)
	set_opacity(TARGET_OPACITY)

	text = get_node("Label")
	pass


func _process(delta):
	var test = Input.is_action_pressed("jump")
	
	if test:
		update_score()
		pass
	
	if exit_state:
		exit_state = false
		if previous_state == S_TIMER:
			timer = 0.0
	if enter_state:
		enter_state = false
	
	if state == S_TIMER:
		timer += delta
		if timer > TIMER_FADEOUT:
			go_to_state(S_ANIMATE)
	elif state == S_ANIMATE:
		var opacity = get_opacity() - OPACITY_ANIM_RATE * delta
		
		if opacity <= TARGET_OPACITY:
			opacity = TARGET_OPACITY
			go_to_state(S_IDLE)
		set_opacity(opacity)
		pass
	pass


# Set opacity back to 100% and moves the node to the timer state
func update_score():
	score += 1
	text.set_text(str(score))
	set_opacity(1.0)
	go_to_state(S_TIMER)
	pass


func go_to_state(new_state):
	if new_state == state:
		return false
	
	previous_state = state
	state = new_state
	enter_state = true
	exit_state = true
	return true