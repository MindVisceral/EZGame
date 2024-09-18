class_name NozzleFlame
extends Node3D


###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

## Reference to the Animation Player that handles the Flames 'turning' 'on' and 'off'
@export var anim_player: AnimationPlayer


###-------------------------------------------------------------------------###
##### Variables
###-------------------------------------------------------------------------###

## Are the Flames turned on currently?
var turned_on: bool = false


###-------------------------------------------------------------------------###
##### Functions
###-------------------------------------------------------------------------###

func _ready() -> void:
	pass
	

## Play the animation that turns the Flames on
func turn_flames_on() -> void:
	## Only turn the Flames on if they are off
	if !turned_on:
		anim_player.play("turn_on")
		turned_on = true
	

## Play the animation that turns the Flames off
func turn_flames_off() -> void:
	## Only turn the Flames off if they are on
	if turned_on:
		anim_player.play("turn_off")
		turned_on = false
	
