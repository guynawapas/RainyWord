extends Node


var player = preload("res://Player.tscn")
var player_dict={}
var players = null
var in_match={}
var rooms = null
var matching = null


func peer_connected(id):
	print(self.get_path())
	var new_player = player.instance()
	new_player.set_id(id)
	player_dict[id] = new_player
	players.add_child(new_player)
	

func peer_disconnected(id):
	player_dict.erase(id)
	for player in players.get_children():
		if(player.id==id):
			player.queue_free()
			return
	pass
	
	
remote func set_player_name(player_name):
	print("called")
	player_dict[get_tree().get_rpc_sender_id()].set_player_name(player_name)
	
remote func test():
	print("test succeed")
	
	
func do_match():#match first 2 player /// will need to be change
	if(player_dict.size()==2):
		var keys = player_dict.keys()
		rpc_id(keys[0],"set_players_name",[player_dict[keys[0]].player_name,player_dict[keys[1]].player_name])
		rpc_id(keys[1],"set_players_name",[player_dict[keys[1]].player_name,player_dict[keys[0]].player_name])
		in_match[0]=player_dict[keys[0]]
		in_match[1]=player_dict[keys[1]]
		player_dict.erase(keys[0])
		player_dict.erase(keys[1])
		
		
func _process(delta):
#	for player in players.get_children():
#		print(player.player_name)
	do_match()
