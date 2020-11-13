extends KinematicBody2D
var speed = 450
var vel = Vector2()
onready var boy = get_node("Char")


func _ready():
	set_process(true)
	

func _process(delta):
	if Input.is_key_pressed(KEY_RIGHT):
		boy.playing=true
		if boy.flip_h==true:
			boy.flip_h=false
		vel = Vector2(speed, 0)
	elif Input.is_key_pressed(KEY_LEFT):
		boy.playing=true
		boy.flip_h=true
		vel = Vector2(-speed, 0)
	elif Input.is_key_pressed(KEY_DOWN):
		boy.playing=true
		vel =Vector2(0,speed)
	elif Input.is_key_pressed(KEY_UP):
		boy.playing=true
		vel=Vector2(0,-speed)
	else:
		vel = Vector2(0, 0)
		boy.playing=false
		boy.set_frame(2)

	move_and_slide(vel,Vector2(0,-1))
