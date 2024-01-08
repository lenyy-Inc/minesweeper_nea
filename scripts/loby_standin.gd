extends Node2D

var time_passed: float = 0
var mine_number: int = 10
var grid_height: int = 4
var grid_width: int = 4
var player_number: int = 0
var player = preload("res://scenes/minesweeper_tiled_board.tscn")
var players:= []

var mine_coords:= []

signal p1_tile_uncovered
signal p2_tile_uncovered

func has_mine(coordinates) -> bool:
	
	return mine_coords.has(coordinates)

func place_mines() -> void:
	
	var grid:= []
	for i in grid_width:
		grid.append([])
		for j in grid_height:
			grid[i].append(Vector2i(i, j))
			
	var x: int
	var y: int 	
	for i in mine_number:
		
		x = randi_range(0, grid_width - 1)
		y= randi_range(0, grid_height - 1)
		
		while has_mine(grid[x][y]):
			x = randi_range(0, grid_width - 1)
			y = randi_range(0, grid_height - 1)
			
			
		mine_coords.append(grid[x][y])

func tile_uncovered(player_num) -> void:

	if player_num == 0
		p1_tile_uncovered.emit()
		return
	p2_tile_uncovered.emit()

func game_end(loser_player_num) -> void:

	print("player %d loss" % (loser_player_num + 1))

func save_input(input_owner_player_number, input)
	var input_owner = players[input_owner_player_number]

func add_player() -> void:

	players.append(player.instantiate())
	add_child(players[player_number])
	players[player_number].lose.connect(game_end)
	players[player_number].tile_uncovered.connect(tile_uncovered)
	players[player_number].input.connect(save_input)
	player_number += 1

func _ready():
	
	place_mines()
	
	add_player()
	add_player()
	
#delta is time since last frame, and process runs every frame
func _process(delta):
	pass
