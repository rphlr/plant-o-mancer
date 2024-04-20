extends Node

@onready var launcher_theme: AudioStreamPlayer = $LauncherTheme
@onready var loop_theme: AudioStreamPlayer = $LoopTheme
@onready var sound_player: AudioStreamPlayer = $SoundPlayer

func _ready():
	pass # Replace with function body.

func play_button_sound():
	sound_player.play()

func play_launcher_theme():
	launcher_theme.play()

func stop_launcher_theme():
	launcher_theme.stop()

func play_loop_theme():
	loop_theme.play()

func _on_loop_theme_finished():
	loop_theme.play()
