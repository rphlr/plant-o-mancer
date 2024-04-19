extends CharacterBody2D

const SPEED = 150.0

@onready var anim = get_node("AnimationPlayer")
@onready var interaction_area = get_node("InteractionArea")

var is_channeling = false
var interaction_time = 0.0
var channel_time = 0.5
var current_target = null
var interact_list = []

func _physics_process(delta):
	if Input.is_action_just_pressed("char_interact") and not is_channeling:
		start_channeling()
	elif is_channeling:
		interaction_time += delta
		if interaction_time >= channel_time:
			stop_channeling()
		return
	var horizontal = Input.get_axis("char_a", "char_d")
	var vertical = Input.get_axis("char_w", "char_s")
	
	velocity.x = horizontal * SPEED
	velocity.y = vertical * SPEED
	handle_animation(horizontal, vertical)
	move_and_slide()

func start_channeling():
	if interact_list:
		is_channeling = true
		interaction_time = 0.0
		anim.play("Channel")

func stop_channeling():
	is_channeling = false
	for x in interact_list:
		x.queue_free()
	interact_list = []
	anim.play("Idle")

func handle_animation(horizontal, vertical):
	if horizontal == -1:
		get_node("AnimatedSprite2D").flip_h = true
	elif horizontal == 1:
		get_node("AnimatedSprite2D").flip_h = false

	if horizontal == 0 and vertical == 0 and not is_channeling:
		anim.play("Idle")
	elif not is_channeling:
		anim.play("Run")

func _on_interaction_area_body_entered(body):
	if body.is_in_group("Interactable"):
		interact_list.append(body)
		

func _on_interaction_area_body_exited(body):
	if body in interact_list:
		interact_list.erase(body)
		
