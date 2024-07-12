extends Node3D

@onready var animPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	if Input.is_action_just_pressed("movement_forward"):
		animPlayer.play("Reload_gun1")
		animPlayer.play("Reload_gun12")

