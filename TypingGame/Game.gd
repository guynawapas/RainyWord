extends Node

var Enemy = preload("res://Spawnable/Enemy.tscn")
var SpecialEnemy = preload("res://Spawnable/SpecialEnemy.tscn")
var Life = preload("res://Spawnable/Life.tscn")
var fxs=FxStat.fxstat
onready var cutsceneclock=$Cutscenetimer
onready var BGclock=$BGTimer
onready var enemy_container = $EnemyContainer
onready var spawn_container = $SpawnContainer
onready var difficulty_value = $MatchInformation/VBoxContainer/DifficultyRow/DiffucultyValue
onready var player_Name_Label = $MatchInformation/VBoxContainer/PlayerScoreRow/PlayerNameLabel
onready var player_score_value = $MatchInformation/VBoxContainer/PlayerScoreRow/PlayerScoreValue
onready var enemy_Name_Label = $MatchInformation/VBoxContainer/EnemyScoreRow/EnemyNameLabel
onready var enemy_Score_Value = $MatchInformation/VBoxContainer/EnemyScoreRow/EnemyScoreValue
onready var game_over_screen = $gameOverScreen/PanelContainer
onready var win_lose_status = $gameOverScreen/PanelContainer/VBoxContainer/CenterContainer/WinLoseStatus
onready var opponent_left_screen = $OpponentLeftScreen/opponentLeftScreen
onready var time_value = $MatchInformation/VBoxContainer/TimerRow/TimeValue
onready var rematch_button = $gameOverScreen/PanelContainer/VBoxContainer/CenterContainer2/HBoxContainer/Rematch
onready var life_container = $MatchInformation/VBoxContainer/LifeRow/LifeContainer
onready var life_pos = $MatchInformation/VBoxContainer/LifeRow/lifePos
onready var concede_button = $MatchInformation/VBoxContainer/ConcedeRow/concedeButton
onready var chatBox = $MatchInformation/VBoxContainer/ChatRow/ChatBox
onready var textChat = $MatchInformation/VBoxContainer/TextChatBox/TextChat
onready var send_chat_button = $MatchInformation/VBoxContainer/ChatRow/SendChat
onready var gamemode = $MatchInformation/VBoxContainer/HBoxContainer/Gamemode
onready var EjectedPlayer = $ejected
onready var cutscene=$cut/PanelContainer
onready var deadcutscene=$cut/PanelContainer/Dead

var current_letter_index=-1

var active_enemy =null
var difficulty = 0


#all timer will be implement on server
func _ready():
	Global.connect("game_end",self,"handle_game_end")
	Global.connect("opponent_return_to_menu",self,"handle_opponent_return_to_menu")
	Global.connect("spawn_enemy",self,"handle_spawn_enemy")
	Global.connect("opponent_chat",self,"opponent_receive_chat") 
	Global.connect("opponent_lost",self,"handle_opponent_lost")

	if fxs==1:
		BgmPlayer.stop()
	if Lobby.is_singlePlayer:
		print("single Player Game")
		enemy_Name_Label.hide()
		enemy_Score_Value.hide()
		rematch_button.hide()
	else:
		rematch_button.disabled = true
	start_game()
	
	
	

func find_new_active_enemy(typed_character:String):
	for enemy in enemy_container.get_children():
		var prompt = enemy.get_prompt()
		var next_character = prompt.substr(0,1)
		if next_character == typed_character:
			print("success",prompt.length())
			active_enemy = enemy
			current_letter_index = 1
			active_enemy.set_next_character(current_letter_index)
			return
			
#Player press keyboard
func _unhandled_input(event:InputEvent)->void:
	if event is InputEventKey and event.is_pressed():
		var typed_event = event as InputEventKey
		if fxs==1:
			TypePlayer.play()
		
		#ignore shift key press/hold
		if typed_event.is_action_pressed("shift"):
			return
		if typed_event.is_action_pressed("ui_select") and active_enemy != null:
			active_enemy.reset_word_color()
			active_enemy = null
			return
		
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		if active_enemy == null:
			find_new_active_enemy(key_typed)
		else:#find new enemy
			var prompt = active_enemy.get_prompt()
			var next_character = prompt.substr(current_letter_index,1)
			if key_typed == next_character:
				print("successfully types %s"%key_typed)
				current_letter_index += 1
				active_enemy.set_next_character(current_letter_index)
				
				if current_letter_index == prompt.length():
					print("done")
					if active_enemy.is_special:
						special_killed()
					else:
						word_killed()#add kill score
					current_letter_index = -1
					active_enemy.queue_free()
					active_enemy = null
			else:
				print("incorrently typed %s instead of %s"%[key_typed,next_character])

#value will need to be sent to server
func word_killed():
	if fxs==1:
		KillPlayer.play()
	Lobby.player_gain_score()
	player_score_value.text = str(Lobby.player_score)

func special_killed():
	if fxs==1:
		KillPlayer.play()
	Lobby.player_gain_special_score()
	player_score_value.text = str(Lobby.player_score)
	
func deduct_life():
	if fxs==1:
		DamagePlayer.play()
	Lobby.deduct_life_hit_bottom()
	var life_con = life_container.get_children()
	for i in range (life_con.size()-1,-1,-1):
		life_con[i].queue_free()
		print(life_con.size())
		if life_con.size()==1:
			if fxs==0:
				deadcutscene.volume_db=-80
			cutscene.show()
			deadcutscene.play()
		return
	
		
func remove_all_enemy():
	concede_button.hide()
	for enemy in enemy_container.get_children():
		enemy.queue_free()


func _on_DeathArea_body_entered(body):
	#normal ememy
	if not body.is_special:
		#also in normal mode
		if Lobby.gamemode == "Normal":
			deduct_life()
	body.queue_free()
	
	
func _on_concedeButton_pressed(): #timer in server should also stop
	if fxs==1:
		ClickPlayer.play()
	BgmPlayer.stop()
	BGclock.start()
	if fxs==1:
		EjectedPlayer.play()
	win_lose_status.text = "Conceded..."
	game_over_screen.show()
	Lobby.on_concedeButton_pressed()
	if not Lobby.is_singlePlayer:
		textChat.show()
		chatBox.show()
		send_chat_button.show()
	remove_all_enemy()
	if fxs==0:
		deadcutscene.volume_db=(-80)
	cutscene.show()
	deadcutscene.play()
	print(deadcutscene.get_audio_track())
	
	
func handle_game_end():
	if fxs==1:
		BgmPlayer.stop()
		WinPlayer.play()
		BGclock.start()
	win_lose_status.text = Lobby.win_lose_status
	game_over_screen.show()
	if not Lobby.is_singlePlayer:
		textChat.show()
		chatBox.show()
		send_chat_button.show()
	remove_all_enemy()
	
func handle_spawn_enemy(word,spawn_index,is_special):
	if fxs==1:
		SpawnPlayer.play()
	var enemy_instance
	if is_special:
		enemy_instance = SpecialEnemy.instance()
	else:
		enemy_instance = Enemy.instance()
	var spawns = spawn_container.get_children()
	enemy_instance.set_difficulty(Lobby.difficulty)
	enemy_instance.position = spawns[spawn_index].global_position
	enemy_container.add_child(enemy_instance)
	enemy_instance.set_word(word)
	enemy_instance.set_difficulty(difficulty)
	print("enemy word: %s at index %d"%[word,spawn_index])

func handle_opponent_lost():
	if fxs==1:
		BgmPlayer.stop()
		WinPlayer.play()
		BGclock.start()
	concede_button.disabled = true


func _on_MainMenu_pressed():
	if fxs==1:
		ClickPlayer.play()
#	if Lobby.opponent_just_left:
#		get_tree().change_scene("res://Menu.tscn")
#		handle_opponent_return_to_menu()
#		#print("emitted")
#	else:
	Lobby.on_main_menu_pressed()
	
func handle_opponent_return_to_menu():
	opponent_left_screen.show()
	

func _on_opponentLeftOkButton_pressed():
	get_tree().change_scene("res://Menu.tscn")
	
	


func _on_Rematch_pressed():
	if fxs==1:
		ClickPlayer.play()
	Lobby.rematch()
	
func start_game():
	game_over_screen.hide()
	opponent_left_screen.hide()
	textChat.hide()
	chatBox.hide()
	send_chat_button.hide()
	textChat.text = " "
	gamemode.text = Lobby.gamemode
	randomize()
	if Lobby.is_singlePlayer:
		player_Name_Label.text = "Your Score: "
	else:
		player_Name_Label.text = Lobby.player_name + " (You): "
		enemy_Name_Label.text = Lobby.opponent_name + ": "
	
	time_value.text = "300"
	difficulty_value.text = "0"
	for life in life_container.get_children():
		life.queue_free()
	for i in range(5):
		var new_life = Life.instance()
		var pos = life_pos.get_children()
		life_container.add_child(new_life)
		new_life.global_position = pos[i].global_position

func _on_SendChat_pressed():
	if fxs==1:
		ClickPlayer.play()
	Lobby.chat_count += 1
	#print(chatBox.text)
	textChat.text = trim_chat(textChat.text) + "\n %s : %s "%[Lobby.player_name ,chatBox.text]
	Lobby.on_SendChat_pressed(textChat.text)
	chatBox.text=""

func trim_chat(chat):
	if Lobby.chat_count >= 7:
		var start_index = chat.find("\n") + 1
		chat = chat.substr(start_index)
		return chat
	else:
		return chat


func opponent_receive_chat(namee,text):
	if fxs==1:
		ClickPlayer.play()
	Lobby.chat_count += 1
	textChat.text = text
	print(text)
	#print("opponent")

func _process(delta):
	time_value.text = str(Lobby.time_left)
	enemy_Score_Value.text = str(Lobby.opponent_score)
	difficulty_value.text = str(Lobby.difficulty)
	if Lobby.can_rematch:
		rematch_button.disabled = false


func _on_BGTimer_timeout():
	BgmPlayer.play()
	pass # Replace with function body.


func _on_ChatBox_text_changed():
	if fxs==1:
		TypePlayer.play()
	pass # Replace with function body.


func _on_Cutscenetimer_timeout():
	pass # Replace with function body.


func _on_Dead_finished():
	cutscene.hide()
	deadcutscene.volume_db=0
	pass # Replace with function body.

