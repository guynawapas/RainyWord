extends Node

var id =- 1
var connected_players = []
var time_left = 500
# Called when the node enters the scene tree for the first time.
func _ready():
	_on_SpawnTimer_timeout()
	

func set_id(id):
	self.id = id
	self.name = str(id)

	


func _on_MatchTimer_timeout():
	time_left -= 1
	Lobby.match_time_tick(id,time_left)
	


func _on_SpawnTimer_timeout():
	var spawn_index = randi()%5
	Lobby.spawn_enemy(id,spawn_index)
	


func _on_DifficultyTimer_timeout():
	Lobby.increase_difficulty(id)
	pass # Replace with function body.
