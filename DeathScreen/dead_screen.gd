extends Node2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Utilities.player_dead:
		position = Utilities.player_dead_position - Vector2(475, 255)
		visible = true
		AudioManager.stop_loop_theme()
		AudioManager.play_death_sound()
		Engine.time_scale = 0

func _on_play_pressed():
	Utilities.switch_scene("SampleGame", self)
	AudioManager.play_loop_theme()

func _on_quit_pressed():
	get_tree().quit()
