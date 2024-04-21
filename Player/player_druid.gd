extends CharacterBody2D

var SPEED = 250
var health: int = 50

@onready var anim = get_node("AnimationPlayer")
@onready var interaction_area = get_node("InteractionArea")
@onready var inputDisplay = $InputDisplay
@onready var camera = $Camera2D

var ally_template = preload("res://Ally/Ally.tscn")

#channeling / growing variables
var is_channeling = false
var interaction_time = 0.0
var channel_time = 2.0
#interaction object list and current target
var current_target = null
var interact_list = []


func _physics_process(delta):
	#handles "space" input and engages channeling logic
	if Input.is_action_just_pressed("char_interact") and not is_channeling:
		start_channeling()
	if is_channeling:
		if inputDisplay.input_checker():
			stop_channeling()
		else:
			return
	var horizontal = Input.get_axis("char_a", "char_d")
	var vertical = Input.get_axis("char_w", "char_s")
	velocity.x = horizontal * SPEED
	velocity.y = vertical * SPEED
	handle_animation(horizontal, vertical)
	move_and_slide()

func handle_animation(horizontal, vertical):
	if horizontal == -1:
		get_node("AnimatedSprite2D").flip_h = false
	elif horizontal == 1:
		get_node("AnimatedSprite2D").flip_h = true
	if horizontal == 0 and vertical == 0 and not is_channeling:
		anim.play("Idle")
	elif not is_channeling:
		anim.play("Run")

# ------------------------ CHANELLING LOGIC --------------------------------- #
func start_channeling():
	if interact_list:
		#for i in interact_list:
			#i.get_node("AnimationPlayer").play("Invoke")
		inputDisplay.init_input_checker()
		is_channeling = true
		interaction_time = 0.0
		anim.play("Channel")

func stop_channeling():
	is_channeling = false
	for x in interact_list:
		summon_ally(x.position)
		x.queue_free()
	interact_list = []
	anim.play("Idle")

# ------------------------ DETECTING INTERACTIBLE OBJECTS ------------------- #

func _on_interaction_area_body_entered(body):
	if body.is_in_group("Interactable"):
		interact_list.append(body)
		body.get_node("AnimationPlayer").play("Invoke")
		
func _on_interaction_area_body_exited(body):
	if body in interact_list:
		interact_list.erase(body)
		body.get_node("AnimationPlayer").play("Idle")

# ------------------------ DEPLOYING ALLY SUMMON  --------------------------- #
func summon_ally(position):
	var summon = ally_template.instantiate()
	var world_node = get_tree().get_root().get_node("Game")
	summon.position = position
	print(summon)
	world_node.add_child(summon)
	print("Summoning ally")
