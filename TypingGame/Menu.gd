extends Node

var finding_match = false
onready var name_label = $nameLabel
onready var searchingScreen = $CanvasLayer/SearchingForPlayerScreen


func _ready():
	searchingScreen.hide()
	name_label.text = "Welcome!  %s"%Lobby.player_name

func _on_FindMatch_pressed():
	if finding_match:
		return
	Lobby.find_match_pressed()
	finding_match = true
	searchingScreen.show()



func _on_SinglePlayer_pressed():
	Lobby.on_singlePlayer_pressed()
	get_tree().change_scene("res://Game.tscn")


func _on_backButton_pressed():
	searchingScreen.hide()
	Lobby.on_button_cancel_find_match_pressed()
	finding_match = false
