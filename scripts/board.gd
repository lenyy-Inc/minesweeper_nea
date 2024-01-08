extends TileMap

var mine_number: int
var grid_height: int 
var grid_width: int 
var player_number: int
var board_height: int
var board_width: int
var mine_coords:= []

const beta_tile_id: int = 1

#making sprites easier to work with
const spritesheet_space:= Vector2i(0, 0)
const spritesheet_left:= Vector2i(1, 0)
const spritesheet_grid_left:= Vector2i(2, 0)
const spritesheet_top_left:= Vector2i(3, 0)
const spritesheet_grid_top_left:= Vector2i(0, 1)
const spritesheet_grid_space:= Vector2i(3, 3)
const spritesheet_bottom_left:= Vector2i(2, 1)
const spritesheet_bottom:= Vector2i(3, 1)
const spritesheet_bottom_right:= Vector2i(0, 2)
const spritesheet_right:= Vector2i(1, 2)
const spritesheet_grid_right:= Vector2i(2, 2)
const spritesheet_top_right:= Vector2i(3, 2)
const spritesheet_grid_top_right:= Vector2i(0, 3)
const spritesheet_grid_top:= Vector2i(1, 3)
const spritesheet_top:= Vector2i(2, 3)

signal lose

			
func make_board() -> void:
	
	#set corners
	set_cell(0, Vector2i(0, 0), beta_tile_id, spritesheet_top_left)
	set_cell(0, Vector2i(board_width - 1, 0), beta_tile_id, spritesheet_top_right)
	set_cell(0, Vector2i(0, board_height - 1), beta_tile_id, spritesheet_bottom_left)
	set_cell(0, Vector2i(board_width - 1, board_height - 1), beta_tile_id, spritesheet_bottom_right)
	
	#set remaining grid corners
	set_cell(0, Vector2i(0, 2), beta_tile_id, spritesheet_grid_top_left)
	set_cell(0, Vector2i(board_width - 1, 2), beta_tile_id, spritesheet_grid_top_right)
	
	#set unique edge tiles
	set_cell(0, Vector2i(0, 1), beta_tile_id, spritesheet_left)
	set_cell(0, Vector2i(board_width - 1, 1), beta_tile_id, spritesheet_right)
	
	#set rows of same tiles
	for i in range(1, board_width - 1):
		set_cell(0, Vector2i(i, 0), beta_tile_id, spritesheet_top)
		set_cell(0, Vector2i(i, board_height - 1), beta_tile_id, spritesheet_bottom)
		set_cell(0, Vector2i(i, 1), beta_tile_id, spritesheet_space)
		set_cell(0, Vector2i(i, 2), beta_tile_id, spritesheet_grid_top)
	
	#set columns of same tiles
	for i in range(3, board_height - 1):
		set_cell(0, Vector2i(0, i), beta_tile_id, spritesheet_grid_left)
		set_cell(0, Vector2i(board_width - 1, i), beta_tile_id, spritesheet_grid_right)
		
	for i in range(1, board_width - 1):
		for j in range(3, board_height - 1):
			set_cell(0, Vector2i(i, j), beta_tile_id, spritesheet_grid_space)
	

func _ready():
	
	player_number = get_parent().player_number
	mine_number = get_parent().mine_number
	grid_width = get_parent().grid_width
	grid_height = get_parent().grid_height
	
	board_height= grid_height + 4
	board_width= grid_width + 2
	
	if player_number == 0:
		get_window().size = Vector2i(64 * board_width * 2, 64 * board_height)
	
	set_position(Vector2i(64 * board_width * (player_number), 0))
	
	make_board()
	mine_coords = get_parent().mine_coords
	
	var child_grid = preload("res://scenes/minesweeper_grid.tscn").instantiate()
	add_child(child_grid) 
	child_grid.lose.connect(pass_loss)
	child_grid.input.connect(pass_input)
	child_grid.tile_uncovered.connect(pass_loss)

func pass_input():
	pass

func pass_loss() -> void:
	lose.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
