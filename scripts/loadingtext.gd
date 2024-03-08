extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	
	get_parent().change_text.connect(change_text)

func change_text(new_text) -> void:
	size = get_window().size
	text = new_text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
