extends Node

var id =- 1
var connected_players = []
var time_left = 300
var difficulty = 0
var is_single_player = false
var one_player_out_of_lives = false
onready var match_timer = $MatchTimer
onready var diff_timer = $DifficultyTimer
onready var spawn_timer = $SpawnTimer
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

func set_id(id):
	self.id = id
	self.name = str(id)




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
	match_timer.start()
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
	Lobby.spawn_enemy(id,is_single_player,spawn_index)
	


func _on_DifficultyTimer_timeout():
	difficulty += 1
	Lobby.increase_difficulty(id,is_single_player,difficulty)
	print("time out")
	
