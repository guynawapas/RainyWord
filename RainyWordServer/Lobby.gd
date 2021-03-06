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
						client_in_room.get_parent().remove_child(client_in_room)
						players.add_child(client_in_room)
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
	var new_room = create_room(single_player_room,node_player.gamemode)
	new_room.is_single_player = true
	node_player.get_parent().remove_child(node_player)
	single_player.add_child(node_player)
	new_room.connected_players = [node_player]
	node_player.room_id = room_id
	rpc_id(rpc_player_id,"update_room_id",room_id)
	#spawn_enemy(room_id,true,1,false)
	room_id += 1
	
remote func set_player_gamemode(gamemode):
	var rpc_player_id = get_tree().get_rpc_sender_id()
	var node_player = players.get_node(str(rpc_player_id))
	node_player.gamemode = gamemode

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
	var matching_players = matching.get_children()
	var matched_players = []
	for matching_player in matching_players:
		if matching_player.gamemode == node_player.gamemode:
			matched_players.append(matching_player)
	if matched_players.size() < 2:
		print(str(node_player.id) + "is waiting for a match...")
		print("waiting for more player")
		return
	else:
		var enemy_player = random_opponent(node_player, matched_players)
		print("Opponent found " + str(enemy_player.id))
		print("moving players in to room...")
		move_to_playing(node_player,enemy_player)
		var new_room = create_room(rooms,node_player.gamemode)
		new_room.connected_players = [node_player,enemy_player]
		node_player.room_id = room_id
		enemy_player.room_id = room_id
		node_player.connected_player = enemy_player
		enemy_player.connected_player = node_player
		rpc_id(node_player.id,"got_opponent",enemy_player.player_name,room_id)
		rpc_id(enemy_player.id,"got_opponent",node_player.player_name,room_id)
		room_id+=1
	
func random_opponent(node_player, matched_players):#find opponent that is not self
	var opponent_list = matched_players
	var opponent_index = randi()%opponent_list.size()
	var opponent = opponent_list[opponent_index]
	if opponent.id != node_player.id:
		return opponent
	else:
		print("refire random")
		opponent = random_opponent(node_player, matched_players)
	return opponent
	
func move_to_playing(node1,node2):
	node1.get_parent().remove_child(node1)
	playing.add_child(node1)
	node2.get_parent().remove_child(node2)
	playing.add_child(node2)
	
func create_room(rooms, gamemode):
	var new_room = room.instance()
	new_room.set_id(room_id)
	rooms.add_child(new_room)
	new_room.set_gamemode(gamemode)
	return new_room

#update time left in clients
func match_time_tick(room_id,is_single_player,time_left):
	if is_single_player:
		for player in single_player_room.get_node(str(room_id)).connected_players:
			rpc_id(player.id,"time_tick",time_left)
	else:
		for player in rooms.get_node(str(room_id)).connected_players:
			if not player.is_game_over:
				rpc_id(player.id,"time_tick",time_left)

func increase_difficulty(room_id,is_single_player,difficulty):
	if is_single_player:
		for player in single_player_room.get_node(str(room_id)).connected_players:
			rpc_id(player.id,"difficulty_increased",difficulty)
	else:
		for player in rooms.get_node(str(room_id)).connected_players:
			if not player.is_game_over:
				rpc_id(player.id,"difficulty_increased",difficulty)
	


func spawn_enemy(room_id,is_single_player,spawn_index,is_special):
	var word = WordLists.get_word()
	if is_single_player:
		for player in single_player_room.get_node(str(room_id)).connected_players:
			rpc_id(player.id,"spawn_enemy",word,spawn_index,is_special)
	else:
		for player in rooms.get_node(str(room_id)).connected_players:
			if not player.is_game_over:
				rpc_id(player.id,"spawn_enemy",word,spawn_index,is_special)



#time runs out o
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
			node_player.is_game_over = true
			rpc_id(node_player.id,"game_end",text)
			rpc_id(player.id,"can_rematch")
			node_player.soft_reset()
		
func check_winner(room):
	print("checking winner")
	var player1 = room.connected_players[0]
	if player1 == null:
		player1 = -1
	var player2 = room.connected_players[1]
	if player2 == null:
		player2 = -1
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
		node_player.player_score = score
	else:
		var player_room = rooms.get_node(str(room_id))
		for player in player_room.connected_players:
			if player.id != get_tree().get_rpc_sender_id():
				rpc_id(player.id,"opponent_gain_score",score)
			else:
				player.player_score = score
				
remote func deduct_life(room_id,life,is_single_player):
	if is_single_player:
		var node_player = single_player.get_node(str(get_tree().get_rpc_sender_id()))
		node_player.life -= 1
		if node_player.life <= 0:
			rpc_id(node_player.id,"game_end","Out of lives!")
			var player_room = single_player_room.get_node(str(room_id))
			player_room.stop_all_timers()
	else:
		var player_room = rooms.get_node(str(room_id))
		for player in player_room.connected_players:
			#player is the one who lose a life
			if player.id == get_tree().get_rpc_sender_id():
				player.life -= 1
				if player.life <= 0:
					#first one to lose by out of lives
					if not player_room.one_player_out_of_lives:
						player.is_game_over = true
						player_room.one_player_out_of_lives = true
						rpc_id(player.id,"game_end","Out of lives!")
						rpc_id(player.connected_player.id,"opponent_lost")
					#second player to lose
					else:
						player.is_game_over = true
						rpc_id(player.id,"game_end",check_winner(player_room))
						rpc_id(player.connected_player.id,"can_rematch")
						rpc_id(player.id,"can_rematch")
						player_room.stop_all_timers()
						
						

remote func player_conceded(is_singlePlayer):
	var rpc_player_id = get_tree().get_rpc_sender_id()
	if is_singlePlayer:
		var node_player = single_player.get_node(str(rpc_player_id))
		var player_room = single_player_room.get_node(str(node_player.room_id))
		player_room.stop_all_timers()
	else:
		var node_player = playing.get_node(str(rpc_player_id))
		var player_room = rooms.get_node(str(node_player.room_id))
		player_room.stop_all_timers()
		node_player.is_game_over = true
		node_player.connected_player.is_game_over = true
		
		var text = node_player.player_name + " conceded!"
		rpc_id(node_player.connected_player.id,"game_end",text)
		rpc_id(node_player.connected_player.id,"can_rematch")
		rpc_id(node_player.id,"can_rematch")



remote func rematch_server(room_id):
	var called_room = rooms.get_node(str(room_id))
	called_room.reset()
	
remote func tell_opponent_rematch(room_id):
	var player_room = rooms.get_node(str(room_id))
	for player in player_room.connected_players:
		if player.id != get_tree().get_rpc_sender_id():
				rpc_id(player.id,"rematch_opponent")
				
remote func sendChat(chatBox,is_singlePlayer,room_id,player_name):
	if is_singlePlayer:
		pass
	else :
		var player_room = rooms.get_node(str(room_id))
		for player in player_room.connected_players:
			if player.id != get_tree().get_rpc_sender_id():
				print("sendChat")
				rpc_id(player.id,"opponent_receive_chat",player_name,chatBox)


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
	
	var player_room = rooms.get_node(str(node_player.room_id))
	
	if node_player.is_game_over and not node_player.opponent_just_left:
		connected_player.opponent_just_left = true
		node_player.hard_reset()
		node_player.get_parent().remove_child(node_player)
		players.add_child(node_player)
		if connected_player.is_game_over:
			connected_player.hard_reset()
			connected_player.get_parent().remove_child(connected_player)
			players.add_child(connected_player)
			player_room.queue_free()
			rpc_id(connected_player.id,"opponent_return_to_menu")
#	else:
#		node_player.hard_reset()
#		node_player.get_parent().remove_child(node_player)
#		players.add_child(node_player)
#		player_room.queue_free()
#		print("room freed from outer else")
	
	
	
func reset_everything():
	
	for player in matching.get_children():
		player.get_parent().remove_child(player)
		players.add_child(player)
		player.hard_reset()
		rpc_id(player.id,"reset_by_server")
		
	for player in single_player.get_children():
		player.get_parent().remove_child(player)
		players.add_child(player)
		player.hard_reset()
		rpc_id(player.id,"reset_by_server")
		
	for player in playing.get_children():
		player.get_parent().remove_child(player)
		players.add_child(player)
		player.hard_reset()
		rpc_id(player.id,"reset_by_server")
		
	for room in rooms.get_children():
		room.queue_free()
		
	for room in single_player_room.get_children():
		room.queue_free()


	
	
	
	
