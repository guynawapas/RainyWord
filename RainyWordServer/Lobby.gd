extends Node

var room = preload("res://Room.tscn")
var player = preload("res://Player.tscn")
var players = null #Players node in server scene
var rooms = null #Rooms node in server scene
var matching = null #Matching node in server scene
var playing = null #Playing node in server scene
var single_player_room = null #SinglePlayerRoom node in server scene
var single_player = null #SinglePlayer node in server scene

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
	for player in single_player.get_children():
		if(player.id==id):
			player.queue_free()
			single_player_room.get_node(str(player.room_id)).queue_free()
			return


remote func set_player_name(player_name):
	print("setting player name: %s"%player_name)
	var rpc_player_id = get_tree().get_rpc_sender_id()
	var node_player = players.get_node(str(rpc_player_id))
	node_player.set_player_name(player_name)

remote func singlePlayer():
	var rpc_player_id = get_tree().get_rpc_sender_id()
	var node_player = players.get_node(str(rpc_player_id))
	var new_room = create_room(single_player_room)
	new_room.is_single_player = true
	node_player.get_parent().remove_child(node_player)
	single_player.add_child(node_player)
	new_room.connected_players = [node_player]
	node_player.room_id = room_id
	rpc_id(rpc_player_id,"update_room_id",room_id)
	spawn_enemy(room_id,true,1)
	room_id += 1
	
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
		var new_room = create_room(rooms)
		new_room.connected_players = [node_player,enemy_player]
		node_player.room_id = room_id
		enemy_player.room_id = room_id
		node_player.connected_player = enemy_player
		enemy_player.connected_player = node_player
		rpc_id(node_player.id,"got_opponent",enemy_player.player_name,room_id)
		rpc_id(enemy_player.id,"got_opponent",node_player.player_name,room_id)
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
	
func create_room(rooms):
	var new_room = room.instance()
	new_room.set_id(room_id)
	rooms.add_child(new_room)
	return new_room

#update time left in clients
func match_time_tick(room_id,is_single_player,time_left):
	if is_single_player:
		for player in single_player_room.get_node(str(room_id)).connected_players:
			rpc_id(player.id,"time_tick",time_left)
	else:
		for player in rooms.get_node(str(room_id)).connected_players:
			rpc_id(player.id,"time_tick",time_left)

func spawn_enemy(room_id,is_single_player,spawn_index):
	var word = WordLists.get_word()
	if is_single_player:
		for player in single_player_room.get_node(str(room_id)).connected_players:
			rpc_id(player.id,"spawn_enemy",word,spawn_index)
	else:
		for player in rooms.get_node(str(room_id)).connected_players:
			rpc_id(player.id,"spawn_enemy",word,spawn_index)



#time runs out or word hit bottom of screen
remote func match_over(room_id,is_single_player):
	var called_room
	if is_single_player:
		called_room = single_player_room.get_node(str(room_id))
		called_room.stop_all_timers()
		var node_player = called_room.connected_players[0]
		rpc_id(node_player.id,"game_end","Your score is %d !"%node_player.player_score)
		node_player.soft_reset()
	else:
		called_room = rooms.get_node(str(room_id))
		var text = check_winner(called_room)
		called_room.stop_all_timers()
		for node_player in called_room.connected_players:
			rpc_id(node_player.id,"game_end",text)
			node_player.soft_reset()
		
func check_winner(room):
	print("checking winner")
	var player1 = room.connected_players[0]
	var player2 = room.connected_players[1]
	var text = ""
	if player1.player_score > player2.player_score:
		text = player1.player_name + " wins!"
	elif player2.player_score > player1.player_score:
		text = player2.player_name + " wins!"
	else:
		text = "It's a tie!"
	return text
	
	
remote func player_gain_score(room_id,score,is_single_player):
	if is_single_player:
		var node_player = single_player.get_node(str(get_tree().get_rpc_sender_id()))
		node_player.player_score += 1
	else:
		var player_room = rooms.get_node(str(room_id))
		for player in player_room.connected_players:
			if player.id != get_tree().get_rpc_sender_id():
				rpc_id(player.id,"opponent_gain_score")
			else:
				player.player_score += 1
				
remote func deduct_score(room_id,score,is_single_player):
	if is_single_player:
		var node_player = single_player.get_node(str(get_tree().get_rpc_sender_id()))
		node_player.player_score -= 1
		if node_player.player_score < 0:
			node_player.player_score = 0
	else:
		var player_room = rooms.get_node(str(room_id))
		for player in player_room.connected_players:
			if player.id != get_tree().get_rpc_sender_id():
				rpc_id(player.id,"opponent_lose_score")
			else:
				player.player_score -= 1
				if player.player_score < 0:
					player.player_score = 0
	

remote func player_conceded(is_singlePlayer):
	var rpc_player_id = get_tree().get_rpc_sender_id()
	if is_singlePlayer:
		var node_player = single_player.get_node(str(rpc_player_id))
		var player_room = rooms.get_node(str(node_player.room_id))
		player_room.stop_all_timers()
#		node_player.get_parent().remove_child(node_player)
#		players.add_child(node_player)
#		single_player_room.get_node(str(node_player.room_id)).queue_free()
#		node_player.hard_reset()
	else:
		var node_player = playing.get_node(str(rpc_player_id))
		var player_room = rooms.get_node(str(node_player.room_id))
		player_room.stop_all_timers()
		for player in player_room.connected_players:
			if player.id != rpc_player_id:
				var text = node_player.connected_player.player_name + " conceded!"
				rpc_id(player.id,"game_end",text)
				print("send game end to %s"%player.player_name)
				
remote func single_player_return_to_menu():
	var rpc_player_id = get_tree().get_rpc_sender_id()
	var node_player = single_player.get_node(str(rpc_player_id))
	node_player.get_parent().remove_child(node_player)
	players.add_child(node_player)
	single_player_room.get_node(str(node_player.room_id)).queue_free()
	node_player.hard_reset()

remote func player_return_to_menu():
	var rpc_player_id = get_tree().get_rpc_sender_id()
	var node_player = playing.get_node(str(rpc_player_id))
	var connected_player = node_player.connected_player
	
	var player_room_id = node_player.room_id
	
	rooms.get_node(str(player_room_id)).queue_free()
	#reset player states
	node_player.hard_reset()
	node_player.get_parent().remove_child(node_player)
	players.add_child(node_player)
	connected_player.hard_reset()
	connected_player.get_parent().remove_child(connected_player)
	players.add_child(connected_player)
	rpc_id(connected_player.id,"opponent_return_to_menu")
	

remote func rematch_server(room_id):
	print("dfghtfhjyj")
	var called_room = rooms.get_node(str(room_id))
	called_room.match_timer.start()
	called_room.diff_timer.start()
	called_room.spawn_timer.start()
	called_room.time_left=50
	
remote func tell_opponent_rematch(room_id):
	var player_room = rooms.get_node(str(room_id))
	for player in player_room.connected_players:
		if player.id != get_tree().get_rpc_sender_id():
				rpc_id(player.id,"rematch_opponent")



remote func reset_game_room(caller_room_id):
	var players_in_room = rooms.get_node(caller_room_id)
	for player in players:
		print("reset!",player.name)
	
	
	
	
