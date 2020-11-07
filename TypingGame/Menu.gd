extends Node

var finding_match = false
onready var name_label = $nameLabel
onready var searchingScreen = $CanvasLayer/SearchingForPlayerScreen
onready var changeNameScreen = $CanvasLayer2/ChangeNameScreen
onready var changeNameTextEdit = $CanvasLayer2/ChangeNameScreen/CenterContainer/VBoxContainer/changeNameTextEdit
onready var game_mode_selection = $Popup
onready var current_mode_value = $CurrentModeValue

func _ready():
	changeNameScreen.hide()
	searchingScreen.hide()
	name_label.text = "Welcome!  %s"%Lobby.player_name
	Global.connect("reset_by_server",self,"handle_reset_by_server")

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

func _on_ChangeName_pressed():
	changeNameScreen.show()
	
func _on_okButton_pressed():
	Lobby.set_player_name(changeNameTextEdit.text)
	Lobby._on_connection_success()
	
	

func _on_NormalMode_pressed():
	game_mode_selection.hide()
	Lobby.set_gamemode("Normal")
	
	current_mode_value.text = Lobby.gamemode
	print("Set to Normal Mode")


func _on_RainyMode_pressed():
	game_mode_selection.hide()
	Lobby.set_gamemode("Rainy")
	current_mode_value.text = Lobby.gamemode
	print("Set to Rainy Mode")


func _on_GameModeButton_pressed():
	game_mode_selection.show()
	
func handle_reset_by_server():
	searchingScreen.hide()
	changeNameScreen.hide()
	
