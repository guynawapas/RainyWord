extends Node

var finding_match = false
onready var name_label = $nameLabel

func _ready():
	name_label.text = "Welcome!  %s"%Lobby.player_name

func _on_FindMatch_pressed():
	if finding_match:
		return
	Lobby.find_match_pressed()
	finding_match = true
	



func _on_SinglePlayer_pressed():
	Lobby.on_singlePlayer_pressed()
	get_tree().change_scene("res://Game.tscn")
