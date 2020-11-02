extends Node

var Enemy = preload("res://Enemy.tscn")

onready var enemy_container = $EnemyContainer
onready var spawn_container = $SpawnContainer
onready var spawn_timer = $SpawnTimer
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

var current_letter_index=-1

var active_enemy =null
var difficulty = 0



#all timer will be implement on server
func _ready():
	Global.connect("game_end",self,"handle_game_end")
	Global.connect("opponent_return_to_menu",self,"handle_opponent_return_to_menu")
	Global.connect("spawn_enemy",self,"handle_spawn_enemy")
	if Lobby.is_singlePlayer:
		print("single Player Game")
		enemy_Name_Label.hide()
		enemy_Score_Value.hide()
		rematch_button.hide()
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
		
		#ignore shift key press/hold
		if typed_event.is_action_pressed("shift"):
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
				#####also need to implement when enemy got score and erease word on our scene######
				if current_letter_index == prompt.length():
					print("done")
					word_killed()#add kill score
					current_letter_index = -1
					active_enemy.queue_free()
					active_enemy = null
			else:
				print("incorrently typed %s instead of %s"%[key_typed,next_character])

#value will need to be sent to server
func word_killed():
	Lobby.player_gain_score()
	player_score_value.text = str(Lobby.player_score)


	
func deduct_score():
	Lobby.deduct_score_hit_bottom()
	player_score_value.text = str(Lobby.player_score)
	
	
#probably will have to move to server
#func _on_SpawnTimer_timeout():
#	spawn_enemy()
#

	
	
#func spawn_enemy():
#	#print("spawnEnemy")
#	var enemy_instance = Enemy.instance()
#	var spawns = spawn_container.get_children()
#	#index will need to be from server
#	var index = randi()%spawns.size()
#	enemy_instance.position = spawns[index].global_position
#	enemy_container.add_child(enemy_instance)
#	enemy_instance.set_difficulty(difficulty)

#will be implement on server
func _on_DifficultyTimer_timeout():
	difficulty += 1
	Global.emit_signal("difficulty_increased",difficulty)
	#print("difficulty increased to %d"%difficulty)
	var new_wait_time = spawn_timer.wait_time - 0.2
	spawn_timer.wait_time = clamp(new_wait_time,1,spawn_timer.wait_time)
	#timer won't be faster than 1 second
	difficulty_value.text = str(difficulty)


func _on_DeathArea_body_entered(body):
	body.queue_free()
	deduct_score()
	
func _on_concedeButton_pressed(): #timer in server should also stop
	win_lose_status.text = "Conceded..."
	game_over_screen.show()
	Lobby.on_concedeButton_pressed()
	remove_all_enemy()
	
func handle_game_end():
	win_lose_status.text = Lobby.win_lose_status
	game_over_screen.show()
	remove_all_enemy()
	
func handle_spawn_enemy(word,spawn_index):
	var enemy_instance = Enemy.instance()
	var spawns = spawn_container.get_children()
	enemy_instance.position = spawns[spawn_index].global_position
	enemy_container.add_child(enemy_instance)
	enemy_instance.set_word(word)
	enemy_instance.set_difficulty(difficulty)
	print("enemy word: %s at index %d"%[word,spawn_index])
	
func _on_MainMenu_pressed():
	if Lobby.opponent_just_left:
		get_tree().change_scene("res://Menu.tscn")
		Global.emit_signal("opponent_return_to_menu")
		print("emitted")
	else:
		Lobby.on_main_menu_pressed()
	
func handle_opponent_return_to_menu():
	opponent_left_screen.show()
	

func _on_opponentLeftOkButton_pressed():
	get_tree().change_scene("res://Menu.tscn")
	
	
func remove_all_enemy():
	spawn_timer.stop()
	for enemy in enemy_container.get_children():
		enemy.queue_free()

func _on_Rematch_pressed():
	Lobby.rematch()
	
func start_game():
	game_over_screen.hide()
	opponent_left_screen.hide()
	randomize()
	if Lobby.is_singlePlayer:
		player_Name_Label.text = "Your Score: "
	else:
		player_Name_Label.text = Lobby.player_name + " (You): "
		enemy_Name_Label.text = Lobby.opponent_name + ": "
	#spawn_timer.start()
	time_value.text = "300"
	#spawn_enemy()
	
func _process(delta):
	time_value.text = str(Lobby.time_left)
	enemy_Score_Value.text = str(Lobby.opponent_score)




