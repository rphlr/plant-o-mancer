class_name Ally
extends CharacterBody2D

const UnitType = Utils.UnitType
const AllyType = Utils.AllyType

var unit_type: UnitType = UnitType.ALLY
var ally_type: String

var speed: int = 240
var attack_power: int = 30

var attack_interval: float = 1.0
var attack_distance: float = 25

var health: int = 100

var is_dying: bool = false
var death_animation_started: bool = false

var time_till_next_attack: float = 0
var target: CharacterBody2D = null

var max_distance_to_player: int = 220
var min_distance_to_player: int = 120

var max_offset = (max_distance_to_player - min_distance_to_player) / 2

var idle_position_direction: int
var idle_player_offset: int

var enemies_in_range = []

var rng = RandomNumberGenerator.new()

@onready var animate: AnimationPlayer = get_node("AnimationPlayer")
@onready var player: CharacterBody2D = $"../Druid"

func _init():
	var ally_types = [
		"DPS", "TANK"
	]
	print("Hello World")
	var ally_type_index = randi_range(0, 1)
	ally_type = ally_types[ally_type_index]
	if ally_type == "DPS":
		pass
	elif ally_type == "TANK":
		pass
	

func _physics_process(delta):
	if not is_dying:
		handle_movement(delta)
	
	handle_animation()

func combine_animation_name(anim_name):
	#print(ally_type + "_" + anim_name)
	return ally_type + "_" + anim_name

func handle_movement(delta):
	if health <= 0:
		is_dying = true
		return
		
	if time_till_next_attack > 0:
		time_till_next_attack -= delta
	
	var is_ready_to_attack = time_till_next_attack <= 0
	
	
	if not has_new_closest_enemy_target():
		if should_remain_idle(delta):
			velocity = Vector2.ZERO
			idle_player_offset = min_distance_to_player + rng.randi_range(0, max_offset)
		else:
			follow_player(delta)


	else:
		var distance_to_target = position.distance_to(target.position)
		var is_target_in_range = distance_to_target <= attack_distance
		
		if not is_target_in_range:
			velocity = position.direction_to(target.position) * speed
		elif is_ready_to_attack:
			time_till_next_attack = attack_interval
			velocity = Vector2.ZERO
			
			animate.play(combine_animation_name("Attack"))
			target.health -= attack_power
			target.target = self
			
	move_and_slide()


func should_remain_idle(delta):
	if not player:
		return
		
	var distance_to_player = position.distance_to(player.position)
	
	if distance_to_player < min_distance_to_player:
		idle_position_direction = -1
	if distance_to_player > max_distance_to_player:
		idle_position_direction = 1
	
	if idle_position_direction == -1:    # Moving away from player
		if distance_to_player > idle_player_offset:
			idle_position_direction = 0
			return true
		else:
			return false
	elif idle_position_direction == 1:   # Moving towards player
		if distance_to_player < idle_player_offset:
			idle_position_direction = 0
			return true
		else:
			return false
			
	return true

func is_in_player_range():
	var distance_to_player = position.distance_to(player.position)
	
	if idle_position_direction == -1:	# Moving away from player
		if distance_to_player > idle_position_direction:
			idle_position_direction = 0
			return true
		else:
			return false
	elif idle_position_direction == 1:	# Moving towards player
		if distance_to_player < idle_position_direction:
			idle_position_direction
			return true
		else:
			return false
		
	return true


func follow_player(delta):
	if not player:
		return
		
	velocity = idle_position_direction * position.direction_to(player.position) * speed

func has_new_closest_enemy_target():
	var new_target_found = false
	var shortest_distance = INF
	
	for enemy in enemies_in_range:
		if not is_instance_valid(enemy):
			enemies_in_range.erase(enemy)
			continue
		var distance = position.distance_to(enemy.position)
		if distance < shortest_distance:
			shortest_distance = distance
			target = enemy
			new_target_found = true
			
	return new_target_found
	


func handle_animation() -> void:
	if is_dying:
		if animate.current_animation != combine_animation_name("Death") and not death_animation_started:
			death_animation_started = true
			animate.play(combine_animation_name("Death"))
		
		if animate.is_playing():
			return
		
		self.queue_free()

		
	if velocity.x < 0:
		get_node("AnimatedSprite2D").flip_h = true
	elif velocity.x > 0:
		get_node("AnimatedSprite2D").flip_h = false
	
	if animate.current_animation != combine_animation_name("Attack") and velocity != Vector2.ZERO:
		animate.play(combine_animation_name("Run"))
	elif animate.current_animation != combine_animation_name("Attack"):
		animate.play(combine_animation_name("Idle"))
	

func _on_target_area_body_entered(body):
	if body.is_in_group("Enemy"):
		if not target:
			target = body
		
		enemies_in_range.append(body)
		
#
#
func _on_target_area_body_exited(body):
	if body == target:
		target = null
	elif body in enemies_in_range:
		enemies_in_range.erase(body)
