extends ParallaxLayer

var objects = []

func _ready():
	for child in get_children():
		print(child.get_class())
		if child.get_class() == "Sprite2D":
			objects.append(child)
