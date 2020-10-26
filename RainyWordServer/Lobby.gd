extends Node


var player = preload("res://Player.tscn")
#var player_dict= {}
var players = null #Players node in server scene
var in_match= {}
var rooms = null #Rooms node in server scene
var matching = null #Matching node in server scene



func peer_connected(id):
	print(self.get_path())
	var new_player = player.instance()
	new_player.set_id(id)
	#player_dict[id] = new_player
	players.add_child(new_player)
	

func peer_disconnected(id):
	#player_dict.erase(id)
	for player in players.get_children():
		if(player.id==id):
			player.queue_free()
			return
	for player in matching.get_children():
		if(player.id==id):
			player.queue_free()
			return
	for player in rooms.get_children():
		if(player.id==id):
			player.queue_free()
			return
	
	
remote func set_player_name(player_name):
	print("setting player name: %s"%player_name)
	var rpc_player_id = get_tree().get_rpc_sender_id()
	var node_player = players.get_node(str(rpc_player_id))
	node_player.set_player_name(player_name)
	#player_dict[rpc_player_id].set_player_name(player_name)
	
remote func find_match():
	var rpc_player_id = get_tree().get_rpc_sender_id()
	var node_player = players.get_node(str(rpc_player_id))
	node_player.get_parent().remove_child(node_player)
	matching.add_child(node_player)
	
	
func do_match():#match first 2 player /// will need to be change
	
	pass
		
func _process(delta):
#	for player in players.get_children():
#		print(player.player_name)
	do_match()
