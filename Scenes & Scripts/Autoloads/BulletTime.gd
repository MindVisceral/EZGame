extends Node

###-------------------------------------------------------------------------###
##### Changable variables
###-------------------------------------------------------------------------###

## Default time_scale. Should always be set to 1.0
var default_time_scale: float = 1.0

## The target time_scale. When time is slowed down, this is the time_scale we're aiming for.
var target_time_scale: float = 0.35

## Time (in seconds) it takes for the time_scale to reach the lower/upper limit;
var time_until_limit: float = 0.4


###-------------------------------------------------------------------------###
##### Regular variables
###-------------------------------------------------------------------------###

## Current time_scale, set to be the same as default_time_scale on _ready().
var time_scale: float = 1.0

## We only need one Tween; If we made a new one on every time, they would interfere with each other
var bullet_time_tween: Tween

## Is the game slowed down at the momet?
var active: bool = false

###-------------------------------------------------------------------------###
##### Setup
###-------------------------------------------------------------------------###

func _ready() -> void:
	time_scale = default_time_scale
	


###-------------------------------------------------------------------------###
##### Core functions
###-------------------------------------------------------------------------###

## Await for input.
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("input_bullet_time"):
		change_time_scale()
		
	

## This function is called when the Player wants to slow down the game or return to default speed
func change_time_scale() -> void:
	## Instantiate the Tween.
	bullet_time_tween = get_tree().create_tween()
	
	## We must make sure the Tween's time works in real time;
	## isn't affected by the time_scale changing.
	bullet_time_tween.set_speed_scale(1.0 / time_scale)
	
	
	## If the game is going at its default speed, speed it up.
	if not active:
		active = true
		
		bullet_time_tween.tween_property(Engine, "time_scale", target_time_scale, time_until_limit)
		bullet_time_tween.tween_property(AudioServer, "playback_speed_scale", \
			target_time_scale, time_until_limit)
		
	
	## Otherwise, tween back to default_time_scale time.
	elif active:
		active = false
		
		bullet_time_tween.tween_property(Engine, "time_scale", default_time_scale, time_until_limit)
		bullet_time_tween.tween_property(AudioServer, "playback_speed_scale", \
			default_time_scale, time_until_limit)
		
	
