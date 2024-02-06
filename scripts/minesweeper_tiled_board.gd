extends TileMap

var mine_number: int
var grid_height: int 
var grid_width: int 
var player_number: int
var board_height: int
var board_width: int
var mine_coords:= []

const beta_tile_id: int = 1
const tile_size_px: int = 64
const dislay_vertical_offset_from_top: int = 104

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
signal win
signal input
signal tile_uncovered
signal opponent_tile_uncovered

var player_score_position_offset:= Vector2i()
var timer_position_offset:= Vector2i()
var opponent_score_position_offset:= Vector2i()

var track_tiles_uncovered: int = 0
var total_clear_tiles: int = 9223372036854775807 #max integer value

			
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
	
	mine_number = get_parent().mine_number
	grid_width = get_parent().grid_width
	grid_height = get_parent().grid_height
	get_parent().opponent_tile_uncovered.connect(pass_opponent_tile_uncovered)
	
	board_height= grid_height + 4
	board_width= grid_width + 2

	get_window().size = Vector2i(64 * board_width, 64 * board_height)
	set_position(Vector2i(tile_size_px * board_width * (player_number), 0))

	make_board()
	mine_coords = get_parent().mine_coords

	player_score_position_offset = Vector2i(104, dislay_vertical_offset_from_top)
	timer_position_offset = Vector2i(board_width/2 *tile_size_px, dislay_vertical_offset_from_top)
	opponent_score_position_offset = Vector2i(board_width * tile_size_px -104 , dislay_vertical_offset_from_top)

	var child_grid = preload("res://scenes/minesweeper_grid.tscn").instantiate()
	add_child(child_grid) 
	child_grid.lose.connect(pass_lose)
	child_grid.input.connect(pass_input)
	child_grid.tile_uncovered.connect(pass_tile_uncovered)


	var child_num_display_timer = preload("res://scenes/num_display_timer.tscn").instantiate()
	add_child(child_num_display_timer)
	child_num_display_timer.lose.connect(pass_lose)

	#will need to add 2 of these, one for each score, figure out where to put them and how to differentiate them lol
	var child_num_display_player_score = preload("res://scenes/num_display_player_score.tscn").instantiate()
	add_child(child_num_display_player_score)
	child_num_display_player_score.win.connect(pass_win)

	var child_num_display_opponent_score = preload("res://scenes/num_display_opponent_score.tscn").instantiate()
	add_child(child_num_display_opponent_score)


func pass_win() -> void:
	win.emit()

func pass_tile_uncovered() -> void:
	track_tiles_uncovered += 1

	if track_tiles_uncovered > total_clear_tiles:
		win.emit()

	tile_uncovered.emit(track_tiles_uncovered)

func pass_input(event) -> void:
	input.emit(event)

func pass_lose() -> void:
	lose.emit()

func pass_opponent_tile_uncovered() -> void:
	opponent_tile_uncovered.emit()


func _process(delta):
	pass
