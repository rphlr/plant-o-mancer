class_name Utils

enum UnitType {
	PLAYER,
	ALLY,
	ENEMY,
}

#func get_target(reference_unit: CharacterBody2D,tree: Node2D, unit_type: UnitType):
	#if unit_type == UnitType.ENEMY:
		#var enemies = tree.get_nodes_in_group("enemies")
		#for enemy in enemies:
			#if not is_instance_valid(enemy):
				#continue
			#var distance = position.distance_to(enemy.position)
			#if distance < shortest_distance:
				#shortest_distance = distance
				#closest_enemy = enemy
		#
		#return closest_enemy
