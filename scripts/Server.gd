extends Node

enum Data{

	join_queue,
	user_id,
	wait,
	lobby_id,
	match_data,

}

var lobbies:= {}
var users:= {}
var matchmaking:= {}
var peer = WebSocketMultiplayerPeer.new()

func place_mines(grid_height, grid_width, mine_number) -> Array:

	var grid:= []
	for i in grid_width:
		grid.append([])
		for j in grid_height:
			grid[i].append(Vector2i(i, j))

	var mine_coords:= []
	var x: int
	var y: int 	
	for i in mine_number:
		
		x = randi_range(0, grid_width - 1)
		y= randi_range(0, grid_height - 1)
		
		while mine_coords.has(grid[x][y]):
			x = randi_range(0, grid_width - 1)
			y = randi_range(0, grid_height - 1)

	return mine_coords

func _ready():
	peer.peer_connected.connect(peer_connected)
	peer.peer_disconnected.connect(peer_disconnected)

func _process(delta):

	peer.poll()

	if peer.get_available_packet_count() > 0:

		var packet = peer.get_packet()

		if packet != null:

			var data = JSON.parse_string(packet.get_string_from_utf8())
			handle_data(data)
	
	
	if users.size() >= 2:
		matchmake()
		

	var ids:= matchmaking.keys()
	for id in ids:
		
		matchmaking[id]["time_waited"] += delta

		var wait_message = {

			"data_type" : Data.wait,
			"data" : matchmaking[id]["time_waited"],

		}
	
		peer.get_peer(id).put_packet((JSON.stringify(wait_message).to_utf8_buffer()))
	


func handle_data(data):

	print("server handling")

	var data_type: int = data["data_type"]

	match data["data_type"]:

		Data.join_queue:

			print("placed into matchmaking")
			matchmaking[data.id] = {

			"id" : data.id,
			"elo" : data.elo,
			"current_opponent" : null,
			"current_elo_gap" : null,
			"time_waited" : 0,

			}

			var extra_user_data = {

			"username" : data.username,
			"elo" : data.elo,

			}

			users[data.id].merge(extra_user_data)
		
		_:

			print("nothing matched server")


func is_better_match(candidate_1, candidate_2, elo_difference) -> bool:

	if candidate_1["current_elo_gap"] <= elo_difference:
		return false
	if candidate_2["current_elo_gap"] <= elo_difference:
		return false

	return true

func matchmake() -> void:


	var in_matchmaking:= []
	var match_conditions: bool 
	var difference_lenience: int
	var elo_difference: int

	in_matchmaking = matchmaking.keys()

	for i in range(0, in_matchmaking.size() - 1):
		print("range not issue")
		for j in range(i + 1, in_matchmaking.size()):

			print("please")
			var candidate_1 = matchmaking[in_matchmaking[i]]
			print(str(candidate_1))
			var candidate_2 = matchmaking[in_matchmaking[j]]
			print(str(candidate_1))

			elo_difference = candidate_1["elo"] - candidate_2["elo"]
			difference_lenience = 5 * (candidate_1["time_waited"] + 1) * (candidate_2["time_waited"] + 1)
			if difference_lenience > 100:
				difference_lenience = 100
			match_conditions = elo_difference <= difference_lenience

			if match_conditions and is_better_match(candidate_1, candidate_2, elo_difference):
				
				candidate_1["current_opponent"] = candidate_2["id"]
				candidate_2["current_opponent"] = candidate_1["id"]
				candidate_1["current_elo_gap"] = elo_difference
				candidate_2["current_elo_gap"] = elo_difference
		
	for key in in_matchmaking:

		var user = matchmaking[key]

		if not matchmaking.has[user]:
			continue

		if (user["current_opponent"] == null):
			continue

		if not matchmaking.has[user["current_opponent"]]:
			user["current_opponent"] = null
			continue

		var user_chosen_opponent = matchmaking[user["current_opponent"]]

		if user["id"] == user_chosen_opponent["current_opponent"]:

			create_new_lobby(user["id"], user_chosen_opponent["id"])

		


func create_new_lobby(player_1_id, player_2_id) -> void:

	var new_lobby_id:= generate_random_id()
	var player_1 = users[player_1_id]
	var player_2 = users[player_2_id]

	lobbies[new_lobby_id] = {

		"id" : new_lobby_id,
		"player_1" : player_1["id"],
		"player_2" : player_2["id"],

	}

	player_1["lobby"] = new_lobby_id 
	player_2["lobby"] = new_lobby_id 

	var send_lobby = {

		"data_type" : Data.lobby_id,
		"id" : new_lobby_id,

	}

	peer.get_peer(player_1["id"]).put_packet((JSON.stringify(send_lobby).to_utf8_buffer()))
	peer.get_peer(player_2["id"]).put_packet((JSON.stringify(send_lobby).to_utf8_buffer()))

	matchmaking.erase[player_1_id]
	matchmaking.erase[player_2_id]

func generate_random_id() -> String:

	var rng = RandomNumberGenerator.new()

	var id:= ""
	for i in range(0, 15):
		id += str(rng.randi_range(0, 9))

	return id


func start_server() -> void:

	peer.create_server(8915)
	print("server_started")

func _on_start_server_button_down():
	
	start_server()


func peer_disconnected(id) -> void:
	pass

func peer_connected(id) -> void:

	print("peer_connected")
	var send_id = {

		"data_type" : Data.user_id,
		"id" : id,

	}
	peer.get_peer(id).put_packet((JSON.stringify(send_id).to_utf8_buffer()))
	print("id should be sent")
	
	users[id] = {

		"id" : id,

	}
