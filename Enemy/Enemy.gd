extends CharacterBody2D

const UnitType = Utils.UnitType

var unit_type: UnitType = UnitType.ENEMY

var speed: int = 100
var attack_power: int = 25

var attack_interval: float = 1.0
var attack_distance: int = 50

var health: int = 100

var is_dying: bool = false
var death_animation_started: bool = false

var time_till_next_attack: float = 0
var target: CharacterBody2D = null

const new_target_interval: float = 1.0
var time_till_new_target: float = new_target_interval
var allies_in_range = []

var enemy_color: String
var enemy_type: String

@onready var animate: AnimationPlayer = get_node("AnimationPlayer")

func init_enemy(_enemy_color, _enemy_type):
	enemy_color = _enemy_color
	enemy_type = _enemy_type
	if enemy_type == "DRILL":
		health = 300
		attack_power = 110
		attack_interval = 0.7
		speed = 275
	elif enemy_type == "KNIGHT":
		health = 400
		attack_power = 90
		attack_interval = 0.9
		speed = 225
	
	if enemy_color == "RED":
		health *= 0.9
		attack_power *= 1.2
		attack_interval *= 1
		speed *= 0.9
	elif enemy_color == "YELLOW":
		health *= 0.8
		attack_power *= 0.9
		attack_interval *= 0.9
		speed *= 1.2
	elif enemy_color == "GREEN":
		health *= 1.2
		attack_power *= 1.1
		attack_interval *= 1.1
		speed *= 0.8
	elif enemy_color == "GOLD":
		health *= 5
		attack_power *= 3
		attack_interval *= 0.7
		speed *= 1.3

func combine_enemy_anim(anim_name):
	return enemy_color + "_" + enemy_type + "_" + anim_name

func _physics_process(delta):
	if not is_dying:
		handle_movement(delta)
	
	handle_animation()


func handle_movement(delta):
	if health <= 0:
		is_dying = true
		return
		
	if time_till_next_attack > 0:
		time_till_next_attack -= delta
	
	target = get_target(delta)
	
	if target:
		var distance_to_target = position.distance_to(target.position)
		var is_target_in_range = distance_to_target <= attack_distance
		
		if not is_target_in_range:
			velocity = position.direction_to(target.position) * speed
		elif time_till_next_attack <= 0:
			time_till_next_attack = attack_interval
			velocity = Vector2.ZERO
			
			animate.play(combine_enemy_anim("ATTACK"))
			target.health -= attack_power
			if target.unit_type in [UnitType.ALLY, UnitType.ENEMY]:
				target.target = self
			
	move_and_slide()


func handle_animation() -> void:
	if is_dying:
		if animate.current_animation != combine_enemy_anim("DEATH") and not death_animation_started:
			death_animation_started = true
			animate.play(combine_enemy_anim("DEATH"))
		
		if animate.is_playing():
			return
		
		self.queue_free()

		
	if velocity.x < 0:
		get_node("AnimatedSprite2D").flip_h = true
	elif velocity.x > 0:
		get_node("AnimatedSprite2D").flip_h = false
	
	if animate.current_animation != combine_enemy_anim("ATTACK") and velocity != Vector2.ZERO:
		animate.play(combine_enemy_anim("RUN"))
	elif animate.current_animation != combine_enemy_anim("ATTACK"):
		animate.play(combine_enemy_anim("IDLE"))


func get_target(delta):
	if target == $"../../Druid":
		target = null
		
	if target and is_instance_valid(target):
		return target
	
	if delta and time_till_new_target > 0:
		time_till_new_target -= delta
		
	var new_target = null
	var shortest_distance = INF
	
	for ally in allies_in_range:
		if not is_instance_valid(ally):
			allies_in_range.erase(ally)
			continue
			
		var distance = position.distance_to(ally.position)
		if distance < shortest_distance:
			shortest_distance = distance
			new_target = ally
			
	if not new_target:
		new_target = $"../../Druid"

	time_till_new_target = new_target_interval
	return new_target


func _on_target_area_body_entered(body):
	if body.is_in_group("Ally"):
		if not target:
			target = body
		
		allies_in_range.append(body)


func _on_target_area_body_exited(body):
	if body == target:
		target = null
		target = get_target(null)
	if body in allies_in_range:
		allies_in_range.erase(body)
