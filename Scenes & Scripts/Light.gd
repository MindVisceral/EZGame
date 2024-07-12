extends Node3D

var frame = 0
const max_frames = 1
@onready var fuck = $LightOmni
var is_fuck_hidden: bool = true

func _ready():
	fuck.hide()
	pass

func _physics_process(delta):
	
	if frame == max_frames:
		fuck.hide()
		is_fuck_hidden = true
		frame = 0
	
	if Input.is_action_pressed("movement_forward") and is_fuck_hidden == true:
		fuck.show()
		is_fuck_hidden = false
		frame += 1
