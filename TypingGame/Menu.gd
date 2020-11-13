extends Node

var finding_match = false
var fxs=FxStat.fxstat
var bgs=BgmStatus.bgmstatus
onready var name_label = $nameLabel
onready var name_labelm = $Node2D/KinematicBody2D/Label
onready var searchingScreen = $CanvasLayer/SearchingForPlayerScreen
onready var changeNameScreen = $CanvasLayer2/ChangeNameScreen
onready var changeNameTextEdit = $CanvasLayer2/ChangeNameScreen/CenterContainer/VBoxContainer/changeNameTextEdit
onready var game_mode_selection = $Popup
onready var current_mode_value = $CurrentModeValue
onready var FindCharacter = $CanvasLayer/FindChar
onready var cutscene=$Cutscene/PanelContainer
onready var sh=$Cutscene/PanelContainer/sh
func _ready():
	BgmPlayer.play()
	changeNameScreen.hide()
	searchingScreen.hide()
	name_label.text = "Welcome!  %s"%Lobby.player_name
	name_labelm.text=Lobby.player_name
	Global.connect("reset_by_server",self,"handle_reset_by_server")
func _on_FindMatch_pressed():
	if fxs==1:
		ClickPlayer.play()
		BgmPlayer.stop()
		FindPlayer.play()
	if finding_match:
		return
	Lobby.find_match_pressed()
	finding_match = true
	searchingScreen.show()
	FindCharacter.show()

func _on_SinglePlayer_pressed():
	cutscene.show()
	if fxs==0:
		sh.volume_db=-80
	sh.play()
	if fxs==1:
		ClickPlayer.play()
	Lobby.on_singlePlayer_pressed()


func _on_backButton_pressed():
	if fxs==1:
		ClickPlayer.play()
	searchingScreen.hide()
	Lobby.on_button_cancel_find_match_pressed()
	finding_match = false
	FindCharacter.hide()

func _on_ChangeName_pressed():
	if fxs==1:
		ClickPlayer.play()
	changeNameScreen.show()
	
func _on_okButton_pressed():
	if fxs==1:
		ClickPlayer.play()
	Lobby.set_player_name(changeNameTextEdit.text)
	Lobby._on_connection_success()
	
	

func _on_NormalMode_pressed():
	if fxs==1:
		ClickPlayer.play()
	game_mode_selection.hide()
	Lobby.set_gamemode("Normal")
	
	current_mode_value.text = Lobby.gamemode
	print("Set to Normal Mode")


func _on_RainyMode_pressed():
	if fxs==1:
		ClickPlayer.play()
	game_mode_selection.hide()
	Lobby.set_gamemode("Rainy")
	current_mode_value.text = Lobby.gamemode
	print("Set to Rainy Mode")


func _on_GameModeButton_pressed():
	if fxs==1:
		ClickPlayer.play()
	game_mode_selection.show()
	
func handle_reset_by_server():
	searchingScreen.hide()
	changeNameScreen.hide()
	
	


func _on_FXoffButton_pressed():
	if fxs==1:
		FxStat.fxstat=0
		fxs=0
	else:
		FxStat.fxstat=1
		fxs=1
	pass # Replace with function body.


func _on_BGMoffButton_pressed():
	if BgmStatus.bgmstatus==1:
		BgmPlayer.stop()
		BgmStatus.bgmstatus=0
	else:
		BgmPlayer.play()
		BgmStatus.bgmstatus=1
		
	
	pass # Replace with function body.


func _on_sh_finished():
	cutscene.hide()
	sh.volume_db=0
	get_tree().change_scene("res://Game.tscn")
	
	pass # Replace with function body.
