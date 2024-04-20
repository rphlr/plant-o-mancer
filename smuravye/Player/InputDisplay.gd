extends Control

@onready var player = $".."
@onready var color = get_node("InputDisplay")

var arrow_scenes = {
	"up" : preload("res://smuravye/qte_arrows/up_arrow.tscn"),
	"down" : preload("res://smuravye/qte_arrows/down_arrow.tscn"),
	"left" : preload("res://smuravye/qte_arrows/left_arrow.tscn"),
	"right" : preload("res://smuravye/qte_arrows/right_arrow.tscn") 
}

var given_input = []
var required_input = []

var arrow_instances = []

# ------------------------ QTE INPUT ---------------------------------------- #
func collect_input():
	if Input.is_action_just_pressed("char_a"):
		given_input.append("left")
		#return "left"
	if Input.is_action_just_pressed("char_d"):
		given_input.append("right")
		#return "right"
	if Input.is_action_just_pressed("char_w"):
		given_input.append("up")
		#return "up"
	if Input.is_action_just_pressed("char_s"):
		given_input.append("down")
		#return "down"

func generate_input():
	required_input.clear()
	var sample_list = ["up", "down", "left", "right"]
	var difficulty = 4
	if len(player.interact_list) > 1:
		difficulty += len(player.interact_list) - 1 
	for i in range(difficulty):
		#required_input.append(sample_list[randi_range(0, len(sample_list) - 1)])
		required_input.append(sample_list[randi() % sample_list.size()])
	return
	
func is_input_correct():
	var arrow_color: AnimatedSprite2D
	for i in range(len(given_input)):
		if given_input[i] == required_input[i]:
			arrow_color = arrow_instances[i]
			arrow_color.set_frame(2)
		elif i >= len(required_input) or (given_input[i] != required_input[i]):
			arrow_color = arrow_instances[i]
			arrow_color.set_frame(1)
			for j in range(len(given_input)):
				arrow_color = arrow_instances[j]
				arrow_color.set_frame(0)
			return false
	#var timer = Timer.new()
	#timer.one_shot = true
	#timer.wait_time = 3
	#timer.connect("timeout", erase_input_display)
	#timer.start()
	return true

func input_checker():
	collect_input()
	if not is_input_correct():
		print("Wrong input, try again!")
		given_input = []
	elif len(given_input) == len(required_input):
		print("Channeling stopped. Correct input provided.")
		print("Given input was: ", given_input)
		given_input = []
		erase_input_display()
		return true
	return false
	
func init_input_checker():
	given_input = []
	generate_input()
	display_required_input()
	print("Required input generated: ", required_input)
	
func display_required_input():
	var arrow_sprite: AnimatedSprite2D
	var counter = 0
	for i in required_input:
		arrow_sprite = arrow_scenes[i].instantiate()
		arrow_sprite.offset = Vector2(counter * 40, 25)
		counter += 1
		arrow_instances.append(arrow_sprite)
		arrow_sprite.z_index = 1
		add_child(arrow_sprite)
		
func erase_input_display():
	for i in arrow_instances:
		i.queue_free()
	arrow_instances.clear()
