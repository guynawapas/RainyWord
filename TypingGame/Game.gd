extends Node

var Enemy = preload("res://Enemy.tscn")

onready var enemy_container = $EnemyContainer
onready var spawn_container = $SpawnContainer
onready var spawn_timer = $SpawnTimer
onready var difficulty_value = $MatchInformation/VBoxContainer/TopRow/DiffucultyValue
onready var player_Name_Label = $MatchInformation/VBoxContainer/Mid2Row/PlayerNameLabel
onready var player_score_value = $MatchInformation/VBoxContainer/Mid2Row/PlayerScoreValue
onready var enemy_Name_Label = $MatchInformation/VBoxContainer/BotRow/EnemyNameLabel
onready var enemy_Score_Value = $MatchInformation/VBoxContainer/BotRow/EnemyScoreValue

var current_letter_index=-1

var active_enemy =null
var difficulty = 0



#all timer will be implement on server
func _ready():
	if Lobby.is_singlePlayer:
		print("single Player Game")
		enemy_Name_Label.hide()
		enemy_Score_Value.hide()
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

#probably will have to move to server
func _on_SpawnTimer_timeout():
	spawn_enemy()
	

	
	
func spawn_enemy():
	#print("spawnEnemy")
	var enemy_instance = Enemy.instance()
	var spawns = spawn_container.get_children()
	#index will need to be from server
	var index = randi()%spawns.size()
	enemy_instance.position = spawns[index].global_position
	enemy_container.add_child(enemy_instance)
	enemy_instance.set_difficulty(difficulty)

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
	
	game_over()
	
func game_over():
	pass
	
func start_game():
	randomize()
	if Lobby.is_singlePlayer:
		player_Name_Label.text = "Your Score: "
	else:
		player_Name_Label.text = Lobby.player_name + " (You): "
		enemy_Name_Label.text = Lobby.opponent_name + ": "
	spawn_timer.start()
	spawn_enemy()
	
func _process(delta):
	
	enemy_Score_Value.text = str(Lobby.opponent_score)
