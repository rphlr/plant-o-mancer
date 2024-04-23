extends Control

@onready var option_menu: TabContainer = $"../Settings"
static var launcher

func _ready():
	$VBoxContainer/Play.grab_focus()
	if launcher == null:
		launcher = 1
		AudioManager.play_launcher_theme()

func reset_focus():
	$VBoxContainer/Play.grab_focus()

func _on_start_pressed():
	Utilities.switch_scene("SampleGame", self)
	if launcher == 1:
		launcher = 2
		AudioManager.stop_launcher_theme()
		AudioManager.play_loop_theme()

func _on_option_pressed():
	hide()
	option_menu.show()
	option_menu.reset_focus()
	AudioManager.play_button_sound()

func _on_quit_pressed():
	get_tree().quit()
