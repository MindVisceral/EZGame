extends Node

## Default time_scale
var default_time_scale: float = 1.0
## Current time_scale
var time_scale: float
## Minimum and maximum time_scale limits
var lower_limit: float = 0.35
var upper_limit: float = 2.0

## Time it takes (in seconds) for the time_scale to reach the lower/upper limit;
var time_until_limit: float = 0.4

## We only need one Tween; If we made a new one on every time, they would interfere with each other
var bullet_time_tween: Tween


func _ready() -> void:
	time_scale = default_time_scale

func _physics_process(delta: float) -> void:
	## If the Player wants to be put into BulletTime mode...
	if Input.is_action_just_pressed("input_bullet_time"):
		
		## If time_scale is ~= default_time_scale time, we tween to bullet time time
		if is_equal_approx(time_scale, default_time_scale):
			##
			bullet_time_tween = get_tree().create_tween()
			bullet_time_tween.tween_property(self, "time_scale", lower_limit, time_until_limit)
		## Otherwise, we tween back to default_time_scale time
		else:
			bullet_time_tween = get_tree().create_tween()
			bullet_time_tween.tween_property(self, "time_scale", default_time_scale, time_until_limit)
	
	## If a time_scale-changing Tween is created, we do the following...
	if bullet_time_tween != null:
		## We make sure the Tween's time works in real time
		## and isn't affected by the time_scale changing
		bullet_time_tween.set_speed_scale(1.0 / time_scale)
		
		## Limit time_scale
		clampf(time_scale, lower_limit, upper_limit)
		
		## Finally, apply time_scale
		Engine.time_scale = time_scale
		AudioServer.playback_speed_scale = time_scale
