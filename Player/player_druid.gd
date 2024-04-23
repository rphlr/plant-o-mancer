extends CharacterBody2D

var unit_type = Utils.UnitType.PLAYER

var SPEED = 250
var health: int = 1000

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
	track_and_update_health()
	if health < 0:
		Utilities.player_dead = true
		camera = $Camera2D
		camera.get_screen_center_position()
		Utilities.player_dead_position = camera.get_screen_center_position()
		#Utilities.player_dead_position = Vector2(camera.limit_left, camera.limit_top)
		#get_tree().change_scene_to_file("res://DeathScreen/dead_screen.tscn")
		#Engine.time_scale = 0
		return
	
	#handles "space" input and engages channeling logic
	if Input.is_action_just_pressed("char_interact") and not is_channeling:
		start_channeling()
	if is_channeling:
		if inputDisplay.input_checker():
			stop_channeling()
		else:
			return
	var horizontal = Input.get_axis("Left", "Right")
	var vertical = Input.get_axis("Up", "Down")
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
	summon.position = position

	var world_node = get_tree().get_root().get_node("SampleGame")
	world_node.add_child(summon)
	print("Summoning ally")


func track_and_update_health():
	var health_frames = $Camera2D/Control.get_node("AnimatedSprite2D")
	
	var max_health = 1000
	var health_per_frame = 50
	var frame_count = 21  # Total number of frames from 0 to 20

	# Calculate frame index based on health
	var frame = floor((health - 50) / health_per_frame)
	frame = max(0, min(frame_count - 1, frame))  # Ensuring frame is within valid range
	print(frame)
	health_frames.set_frame(frame)
