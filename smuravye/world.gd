extends Node2D

@onready var player = $Druid

var distance_travelled = 0
var last_player_position = null
var spawn_distance = 800

var flower_scene = preload("res://smuravye/sprites/flower.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	last_player_position = player.position.x
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_distance_travelled()
	try_spawn_flower()
	spawn_enemies()
	
func update_distance_travelled():
	if last_player_position:
		var movement = player.position.x - last_player_position
		distance_travelled += movement
	last_player_position = player.position.x
	
func try_spawn_flower():
	if distance_travelled >= spawn_distance:
		spawn_flower()
		distance_travelled -= spawn_distance
		
func spawn_flower():
	for i in range(6):
		var flower = flower_scene.instantiate()
		var y_random = randi_range(70, 500)
		var x_random = randi_range(player.position.x + spawn_distance, player.position.x + spawn_distance + 400)
		flower.position = Vector2(x_random, y_random)
		add_child(flower)
	
	
func spawn_enemies():
	pass
 
