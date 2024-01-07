extends Sprite2D

signal test
# Called when the node enters the scene tree for the first time.
func _ready():
	test.emit("meow")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
