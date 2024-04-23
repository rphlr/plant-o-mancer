extends Node2D

@onready var ui_layer: CanvasLayer = $CanvasLayer
@onready var settings: TabContainer = $CanvasLayer/Panel/Settings

var static_settings

'''
Flow chart
Game <==> Pause Menu ==> Settings
'''

func _ready():
	ui_layer.hide()

func _input(event: InputEvent):
	if event.is_action_pressed("Escape"):
		if not ui_layer.visible:
			show_ui_layer()
		else:
			resume_game()

func show_ui_layer():
	pause_game()
	reset_focus()
	ui_layer.show()
	if static_settings == 1:
		settings.show()
		settings.reset_focus()

func reset_focus():
	$CanvasLayer/Panel/PauseMenu/Resume.grab_focus()

func pause_game():
	Engine.time_scale = 0

func resume_game():
	Engine.time_scale = 1
	settings.hide()
	ui_layer.hide()

func _on_resume_pressed():
	resume_game()

func _on_option_pressed():
	$CanvasLayer/Panel/PauseMenu.hide()
	static_settings = 1
	settings.show()
	settings.reset_focus()

func _on_main_menu_pressed():
	Utilities.switch_scene("`", self)


@onready var player = $Druid

var distance_travelled = 0
var last_player_position = null

var flower_wave_num = 0
var flower_spawn_distance = 800
var flower_scene = preload("res://Flower/Flower.tscn")

var enemy_wave_num = 0
var enemy_space_distance = 400
var enemy_scene = preload("res://Enemy/Enemy.tscn")

const blue_enemy = "BLUE"
const red_enemy = "RED"
const yello_enemy = "YELLOW"
const green_enemy = "GREEN"
const gold_enemy = "GOLD"
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_distance_travelled()
	try_spawn_flower()
	try_spawn_enemies()
	
func update_distance_travelled():
	if last_player_position:
		distance_travelled += player.position.x - last_player_position
		
	last_player_position = player.position.x
	
func get_off_screen_position() -> Vector2:
	randomize()
	var x_min = player.position.x + flower_spawn_distance
	var x_max = x_min + 400
	
	var x_random = randi_range(x_min, x_max)
	var y_random = randi_range(70, 500)
	
	return Vector2(x_random, y_random)
	
func try_spawn_flower():
	if flower_wave_num * flower_spawn_distance <= distance_travelled:
		spawn_flower()
		flower_wave_num += 1


func spawn_flower():
	for i in range(7):
		var flower = flower_scene.instantiate()
		flower.position = get_off_screen_position()
		add_child(flower)
	
	
func try_spawn_enemies():
	if enemy_wave_num * enemy_space_distance <= distance_travelled:
		spawn_enemies(enemy_wave_num)
		enemy_wave_num += 1


func spawn_enemies(wave_num: int):
	var wave = get_wave_enemies(wave_num)
	if not wave:
		wave = generate_enemies(wave_num)

	var enemy_type
	var enemy_type_index
	var enemy_types = ["DRILL", "KNIGHT"]
	
	for enemy_name in wave:
		enemy_type_index = randi_range(0, 1)
		enemy_type = enemy_types[enemy_type_index]
		
		var enemy = enemy_scene.instantiate()
		
		enemy.init_enemy(enemy_name, enemy_type)
		enemy.position = get_off_screen_position()
		
		get_node("Enemies").add_child(enemy)
		

func get_wave_enemies(wave_num: int):
	var wave_lookup = {
		0: [blue_enemy, blue_enemy],
		1: [blue_enemy, red_enemy],
		2: [blue_enemy, red_enemy, red_enemy],
		3: [blue_enemy, red_enemy, yello_enemy, green_enemy],
		4: [red_enemy, yello_enemy, green_enemy],
		5: [gold_enemy],
	}
	
	if wave_num not in wave_lookup:
		print("no wave num")
		return null
	
	return wave_lookup[wave_num]
 

func generate_enemies(wave_num):
	var wave = []
	if wave_num % 5 == 0:
		for i in range(wave_num / 5):
			wave.append(gold_enemy)
	else:
		var num_enemies = round(flower_wave_num * 2 / 3)
		var possible_enemies = [blue_enemy, red_enemy, yello_enemy, green_enemy]
		
		var enemy_index
		for i in range(num_enemies):
			enemy_index = randi_range(0, len(possible_enemies) - 1)
			wave.append(possible_enemies[enemy_index])
		
			
	return wave
