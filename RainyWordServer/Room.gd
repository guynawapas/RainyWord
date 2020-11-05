extends Node

var id =- 1
var connected_players = []
var time_left = 300
var difficulty = 0
var is_single_player = false
var one_player_out_of_lives = false
var gamemode = ""
onready var match_timer = $MatchTimer
onready var diff_timer = $DifficultyTimer
onready var spawn_timer = $SpawnTimer
onready var delay_timer = $Delay

var rain_array = [0,1,2,3,4]
var rain_index = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

func set_id(id):
	self.id = id
	self.name = str(id)
	

func set_gamemode(gamemode):
	self.gamemode = gamemode
	if gamemode == "Rainy":
		print("wait time set to 0.4")
		spawn_timer.wait_time = 0.4
		diff_timer.stop()
		
	else:
		spawn_timer.wait_time = 2
		


func _on_MatchTimer_timeout():
	time_left -= 1
	if time_left <= 0 :
		stop_all_timers()
		Lobby.match_over(id,is_single_player)
	else:
		Lobby.match_time_tick(id,is_single_player,time_left)
	#print("timer: %d"%time_left)

func stop_all_timers():
	match_timer.stop()
	diff_timer.stop()
	spawn_timer.stop()
	
func reset():
	delay_timer.start()
	diff_timer.start()
	spawn_timer.start()
	time_left = 300
	difficulty = 0
	one_player_out_of_lives = false
	for player in  connected_players:
		player.soft_reset()


func _on_SpawnTimer_timeout():
	randomize()
	var spawn_index = randi()%5
	var special_chance = randi()%10
	#print(special_chance)
	if special_chance == 4 and gamemode == "Normal":
		#print("special enemy! %d"%time_left)
		Lobby.spawn_enemy(id,is_single_player,spawn_index,true)
	elif gamemode == "Rainy":
		#print(rain_array)
		spawn_rainy(rain_array[rain_index])
		rain_index += 1
		if rain_index >= 5:
			rain_array.shuffle()
			rain_index = 0
	else:
		Lobby.spawn_enemy(id,is_single_player,spawn_index,false)
	
func spawn_rainy(index):
	#print("spawn at: %d"%index)
	Lobby.spawn_enemy(id,is_single_player,index,false)

func _on_DifficultyTimer_timeout():
	difficulty += 1
	Lobby.increase_difficulty(id,is_single_player,difficulty)
	print("time out")
	


func _on_Delay_timeout():
	match_timer.start()
	rain_array.shuffle()


