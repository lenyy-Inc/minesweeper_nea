extends Node

enum Data{

	join_queue,
	id,
	wait,
	match_data,

}

enum Modes{

	small,
	medium,
	large,
	custom,

}

var mine_coords:= []

var window = JavaScriptBridge.get_interface("window")
var peer = WebSocketMultiplayerPeer.new()
var id = 0 


#gotten from javascript
var elo: int = 0
var username: String = window.username
var game_mode = window.game_mode


var mine_number: int 
var grid_width: int 
var grid_height: int 

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

func _ready():

	get_board_dimensions_from_mode()
	var child_board = preload("res://scenes/minesweeper_board.tscn").instantiate()
	add_child(child_board)


func get_board_dimensions_from_mode() -> void:

	match game_mode:

		Modes.small:

			mine_number = 10
			grid_height = 10
			grid_width = 10

		Modes.medium:

			mine_number = 40
			grid_height = 16
			grid_width = 16

		Modes.large:

			mine_number = 99
			grid_height = 16
			grid_width = 30

		Modes.custom:

			mine_number = window.mine_number
			grid_height = window.grid_height
			grid_width = window.grid_width
	


func _process(delta):

	peer.poll()
	
	if peer.get_available_packet_count() > 0:

		var packet = peer.get_packet()

		if packet != null:

			var data = JSON.parse_string(packet.get_string_from_utf8())

			print(data)
			if data.data_type == Data.id:
				id = data.id
				print("my id is " + str(id))
				join_matchmaking()

func join_matchmaking() -> void:

	var data = {

		"data_type" : Data.join_queue,
		"username" : "test",
		"elo" : elo

	}
	peer.put_packet(JSON.stringify(data).to_utf8_buffer())

func connect_to_server() -> void:

	peer.create_client("ws://127.0.0.1:8915")
	print("client_started")


	

func _on_start_client_button_down():
	
	connect_to_server()



func _on_send_test_packet_button_down():

	var message = {

		"data_type" : Data.join_queue,
		"data" : "test",

	}
	#print(message)
	var message_bytes = JSON.stringify(message).to_utf8_buffer()
	peer.put_packet(message_bytes)
