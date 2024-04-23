extends Node

@onready var launcher_theme: AudioStreamPlayer = $LauncherTheme
@onready var loop_theme: AudioStreamPlayer = $LoopTheme
@onready var sound_player: AudioStreamPlayer = $SoundPlayer
@onready var death_sound: AudioStreamPlayer = $DeathSound

func _ready():
	pass

func play_button_sound():
	sound_player.play()

func play_launcher_theme():
	launcher_theme.play()

func stop_launcher_theme():
	launcher_theme.stop()

func play_loop_theme():
	loop_theme.play()

func play_death_sound():
	death_sound.play()

func stop_loop_theme():
	loop_theme.stop()

func _on_loop_theme_finished():
	loop_theme.play()
