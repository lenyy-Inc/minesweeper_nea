extends Sprite2D

var mine_number: int
var board_height: int 
var board_width: int
var player_number: int

func _ready():
	
	player_number = get_parent().player_number
	set_position(Vector2i(384 * (player_number + 1), 448))
	mine_number = get_parent().mine_number
	board_width = get_parent().board_width
	board_height = get_parent().board_height
	var child_grid = preload("res://scenes/minesweeper_grid.tscn").instantiate()
	add_child(child_grid)
		

func _process(delta):
	pass
