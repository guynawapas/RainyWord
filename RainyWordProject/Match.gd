extends Node


var player1_name=""
var player2_name=""


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
	
func set_players_name(player_names:Array):
	player1_name=player_names[0]
	player2_name=player_names[1]
