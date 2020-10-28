extends Node

var room = preload("res://Room.tscn")
var player = preload("res://Player.tscn")
var players = null #Players node in server scene
var rooms = null #Rooms node in server scene
var matching = null #Matching node in server scene
var playing = null #Playing node in server scene
var singlePlayer = null #SinglePlayer node in server scene
var in_match = {}
var room_id = 0

func peer_connected(id):
	print(self.get_path())
	var new_player = player.instance()
	new_player.set_id(id)
	players.add_child(new_player)
	

func peer_disconnected(id):
	
	for player in players.get_children():
		if(player.id==id):
			player.queue_free()
			return
	for player in matching.get_children():
		if(player.id==id):
			player.queue_free()
			return
	for player in playing.get_children():
		if(player.id==id):
			print("player in room "+str(player.room_id)+" disconnected")
			var room_disconnected = rooms.get_node(str(player.room_id))
			if room_disconnected != null:
				for client_in_room in room_disconnected.connected_players:
					if client_in_room.id != id:
						rpc_id(client_in_room.id,"opponent_disconnected")
					print(client_in_room.player_name)
				room_disconnected.queue_free()
			player.queue_free()
			return
	for player in singlePlayer.get_children():
		if(player.id==id):
			player.queue_free()
			return


remote func set_player_name(player_name):
	print("setting player name: %s"%player_name)
	var rpc_player_id = get_tree().get_rpc_sender_id()
	var node_player = players.get_node(str(rpc_player_id))
	node_player.set_player_name(player_name)

remote func singlePlayer():
	var rpc_player_id = get_tree().get_rpc_sender_id()
	var node_player = players.get_node(str(rpc_player_id))
	node_player.get_parent().remove_child(node_player)
	singlePlayer.add_child(node_player)
	
remote func find_match():
	var rpc_player_id = get_tree().get_rpc_sender_id()
	var node_player = players.get_node(str(rpc_player_id))
	node_player.get_parent().remove_child(node_player)
	matching.add_child(node_player)
	do_match(node_player)
	
remote func cancel_find_match():
	var rpc_player_id = get_tree().get_rpc_sender_id()
	var node_player = matching.get_node(str(rpc_player_id))
	node_player.get_parent().remove_child(node_player)
	players.add_child(node_player)
	
func do_match(node_player):
	if matching.get_child_count() < 2:
		print(str(node_player.id) + "is waiting for a match...")
		print("waiting for more player")
		return
	else:
		var enemy_player = random_opponent(node_player)
		print("Opponent found " + str(enemy_player.id))
		print("moving players in to room...")
		move_to_playing(node_player,enemy_player)
		var new_room = create_room()
		new_room.connected_players = [node_player,enemy_player]
		node_player.room_id = room_id
		enemy_player.room_id = room_id
		rpc_id(node_player.id,"got_opponent",enemy_player.player_name,room_id)
		rpc_id(enemy_player.id,"got_opponent",node_player.player_name,room_id)
		node_player.timer_start()
		enemy_player.timer_start()
		room_id+=1
	
func random_opponent(node_player):#find opponent that is not self
	var opponent_list = matching.get_children()
	var opponent_index = randi()%matching.get_child_count()
	var opponent = opponent_list[opponent_index]
	if opponent.id != node_player.id:
		return opponent
	else:
		print("refire random")
		opponent = random_opponent(node_player)
	return opponent
	
func move_to_playing(node1,node2):
	node1.get_parent().remove_child(node1)
	playing.add_child(node1)
	node2.get_parent().remove_child(node2)
	playing.add_child(node2)
	
func create_room():
	var new_room = room.instance()
	new_room.set_id(room_id)
	rooms.add_child(new_room)
	return new_room
	
	
remote func player_gain_score(score,room_id):
	var player_room = rooms.get_node(str(room_id))
	for player in player_room.connected_players:
		if player.id != get_tree().get_rpc_sender_id():
			rpc_id(player.id,"opponent_gain_score")
		else:
			player.player_score += 1



remote func reset_game_room(caller_room_id):
	var players_in_room = rooms.get_node(caller_room_id)
	for player in players:
		print("reset!",player.name)
	
	
	
	
