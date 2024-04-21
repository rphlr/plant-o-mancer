extends Node2D

@onready var player = $Druid

var distance_travelled = 0
var last_player_position = null

var flower_wave_num = 0
var flower_spawn_distance = 800
var flower_scene = preload("res://Flower/Flower.tscn")

var enemy_wave_num = 0
var enemy_space_distance = 400
var enemy_scene = preload("res://Enemy/Enemy.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	last_player_position = player.position.x
	
	

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
	for i in range(6):
		var flower = flower_scene.instantiate()
		flower.position = get_off_screen_position()
		add_child(flower)
	
	
func try_spawn_enemies():
	if enemy_wave_num * enemy_space_distance <= distance_travelled:
		spawn_enemies(enemy_wave_num)
		enemy_wave_num += 1


func spawn_enemies(wave_num: int):
	var num_enemies = 3 + randi_range(wave_num, wave_num * 2)
	for i in range(num_enemies):
		var enemy = enemy_scene.instantiate()
		enemy.position = get_off_screen_position()
		
		get_node("Enemies").add_child(enemy)
 
