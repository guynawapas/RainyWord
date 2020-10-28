extends KinematicBody2D


onready var prompt = $RichTextLabel
onready var prompt_text = prompt.text

export (Color) var blue = Color("#4682b4")
export (Color) var red = Color("#a65455")
export (Color) var green = Color("#639765")
export (float) var speed = 100

func _physics_process(delta):
	var direction = Vector2(0,speed)
	move_and_slide(direction)
#	get_node("Sprite").global_position.y += speed
#	get_node("RichTextLabel").rect_global_position.y += speed

#text will be handle on server
func _ready():
	#
	prompt_text = WordList.get_word()
	prompt.parse_bbcode("[center]" + prompt_text + "[/center]")
	Global.connect("difficulty_increased",self,"handle_difficulty_increased")


func get_prompt()->String:
	return prompt_text


func set_difficulty(difficulty):
	handle_difficulty_increased(difficulty)
	
func handle_difficulty_increased(new_difficulty):
	var new_speed = speed + (0.5*new_difficulty)
	speed = clamp(new_speed, speed, 300)
####################################
#blue = typed letter
#green = current letter
#red = not typed letter
####################################
func set_next_character(next_character_index):
	var blue_text = get_bbcode_color_tag(blue) + prompt_text.substr(0,next_character_index) + "[/color]"
	var green_text = get_bbcode_color_tag(green) + prompt_text.substr(next_character_index,1) + "[/color]"
	var red_text = ""
	
	if next_character_index!=prompt_text.length():
		red_text = get_bbcode_color_tag(red) + prompt_text.substr(next_character_index + 1,prompt_text.length() - next_character_index + 1) + "[/color]"
	
	prompt.parse_bbcode("[center]" + blue_text + green_text + red_text + "[/center]")
	
	
func get_bbcode_color_tag(color:Color)->String:#false mean no ff infront of color code
	return "[color=#" + color.to_html(false) + "]"