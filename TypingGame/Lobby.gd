extends Node


const PORT = 4242
const IP_ADDRESS = "172.20.10.3"

var player_name= ""
var opponent_name= ""
var is_singlePlayer = false
var player_score = 0
var opponent_score = 0
var room_id  = -1
var win_lose_status = ""
var opponent_just_left = false
var time_left = 300
var difficulty = 0
var life = 5
var can_rematch = false
var chat_count = 0
var gamemode = "Normal"

func set_player_name(name):
	self.player_name = name
	

func on_buttonConnect_pressed():
	var network = NetworkedMultiplayerENet.new()
	network.create_client(IP_ADDRESS,PORT)
	get_tree().set_network_peer(network)
	print("connecting to server")
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_success")
	network.connect("server_disconnected",self,"_on_server_disconnected")
	
	
func _on_connection_success():
	print("success")
	#set player name in server and go to menu screen
	rpc_id(1,"set_player_name",player_name)
	get_tree().change_scene("res://Menu.tscn")
	
func _on_server_disconnected():
	get_tree().change_scene("res://FirstPage.tscn")

func on_buttonDisconnect_pressed():
	get_tree().set_network_peer(null)

func on_singlePlayer_pressed():
	rpc_id(1,"singlePlayer")
	soft_reset()
	is_singlePlayer = true
	
func on_button_cancel_find_match_pressed():
	rpc_id(1,"cancel_find_match")
	
func on_concedeButton_pressed():
	rpc_id(1,"player_conceded",is_singlePlayer)
	

func on_main_menu_pressed():
	if is_singlePlayer:
		is_singlePlayer = false
		rpc_id(1,"single_player_return_to_menu")
	else:
		rpc_id(1,"player_return_to_menu")
	get_tree().change_scene("res://Menu.tscn")

remote func opponent_disconnected():
	opponent_name = ""
	room_id = -1
	soft_reset()
	get_tree().change_scene("res://Menu.tscn")

func find_match_pressed():
	rpc_id(1,"find_match")

func set_gamemode(gamemode):
	rpc_id(1,"set_player_gamemode",gamemode)
	self.gamemode = gamemode

remote func got_opponent(opponent_name,room_id):
	soft_reset()
#	Global.emit_signal("set_opponent_name",opponent)
	self.opponent_name = opponent_name
	self.room_id = room_id
	print("got opponent",opponent_name)
	time_left = 300
	get_tree().change_scene("res://Game.tscn")
	
remote func game_end(status):
	
	print("received game end")
	win_lose_status = status
	Global.emit_signal("game_end")

remote func opponent_return_to_menu():
	soft_reset()
	opponent_just_left = true
	Global.emit_signal("opponent_return_to_menu")

#------------------------------------------------------------------
#game logic
#------------------------------------------------------------------
func player_gain_score():
	self.player_score += 1
	if is_singlePlayer:
		rpc_id(1,"player_gain_score",room_id,self.player_score,true)
	else:
		rpc_id(1,"player_gain_score",room_id,self.player_score,false)

func player_gain_special_score():
	self.player_score += 5
	if is_singlePlayer:
		rpc_id(1,"player_gain_score",room_id,self.player_score,true)
	else:
		rpc_id(1,"player_gain_score",room_id,self.player_score,false)

remote func opponent_lost():
	Global.emit_signal("opponent_lost")


remote func opponent_gain_score(new_score):
	print(opponent_name + "gained score!")
	self.opponent_score = new_score

remote func time_tick(time_left):
	self.time_left = time_left

remote func difficulty_increased(new_difficulty):
	print("current difficulty: ",new_difficulty)
	self.difficulty = new_difficulty
	Global.emit_signal("difficulty_increased",new_difficulty)

remote func spawn_enemy(word,spawn_index,is_special):
	Global.emit_signal("spawn_enemy",word,spawn_index,is_special)
	
func deduct_life_hit_bottom():
	self.life -= 1
	if self.life <= 0 :
		self.life = 0
	if is_singlePlayer:
		rpc_id(1,"deduct_life",room_id,self.life,true)
	else:
		rpc_id(1,"deduct_life",room_id,self.life,false)
	#soft_reset()
	#rpc_id(1,"match_over",room_id,is_singlePlayer)
	
func on_SendChat_pressed(chatBox):
	rpc_id(1,"sendChat",chatBox,is_singlePlayer,room_id,player_name)
	
remote func opponent_receive_chat(namee,text):
	print("oppenont_receive_chat")
	Global.emit_signal("opponent_chat",namee,text)
	
	
#--------------------------------------------------------------------
remote func update_room_id(room_id):
	self.room_id = room_id

remote func can_rematch():
	print("received rematch true")
	self.can_rematch = true

func rematch():
	soft_reset()
	get_tree().change_scene("res://Game.tscn")
	rpc_id(1,"rematch_server",room_id)
	rpc_id(1,"tell_opponent_rematch",room_id)

remote func rematch_opponent():
	soft_reset()
	get_tree().change_scene("res://Game.tscn")
	rpc_id(1,"rematch_server",room_id)

remote func soft_reset():
	player_score = 0
	opponent_score = 0
	time_left = 300
	opponent_just_left = false
	difficulty = 0
	life = 5
	can_rematch = false
	chat_count = 0

remote func hard_reset():
	opponent_name= ""
	is_singlePlayer = false
	soft_reset()

remote func reset_by_server():
	hard_reset()
	get_tree().change_scene("res://Menu.tscn")
	Global.emit_signal("reset_by_server")


