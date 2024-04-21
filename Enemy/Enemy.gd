class_name Enemey
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

@onready var animate: AnimationPlayer = get_node("AnimationPlayer")


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
	
	var is_ready_to_attack = time_till_next_attack <= 0
	
	target = get_target(delta)
	
	if target:
		var distance_to_target = position.distance_to(target.position)
		var is_target_in_range = distance_to_target <= attack_distance
		
		if not is_target_in_range:
			velocity = position.direction_to(target.position) * speed
		elif is_ready_to_attack:
			time_till_next_attack = attack_interval
			velocity = Vector2.ZERO
			
			animate.play("Attack")
			target.health -= attack_power
			if target.unit_type in [UnitType.ALLY, UnitType.ENEMY]:
				target.target = self
			
	move_and_slide()


func handle_animation() -> void:
	if is_dying:
		if animate.current_animation != "Death" and not death_animation_started:
			death_animation_started = true
			animate.play("Death")
		
		if animate.is_playing():
			return
		
		self.queue_free()

		
	if velocity.x < 0:
		get_node("AnimatedSprite2D").flip_h = true
	elif velocity.x > 0:
		get_node("AnimatedSprite2D").flip_h = false
	
	if animate.current_animation != "Attack" and velocity != Vector2.ZERO:
		animate.play("Run")
	elif animate.current_animation != "Attack":
		animate.play("Idle")


func get_target(delta):
	if target and is_instance_valid(target):
		return target
	
	if time_till_new_target > 0:
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
		target = get_target(null)
	if body in allies_in_range:
		allies_in_range.erase(body)
