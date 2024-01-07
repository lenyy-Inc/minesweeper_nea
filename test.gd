extends Sprite2D

func printer(arg) -> void:
	print(arg)
# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().test.connect(printer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
