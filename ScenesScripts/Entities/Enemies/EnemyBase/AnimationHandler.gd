class_name AnimationHandler
extends Node


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export var model_animation_player: AnimationPlayer

@export_group("Exported Animations")

@export var animation_names: Array[String]

###-------------------------------------------------------------------------###
##### Regular variables
###-------------------------------------------------------------------------###

## Reference to the Enemy so that their functions and variables can be accessed directly
var enemy: EnemyBase


###-------------------------------------------------------------------------###
##### Functions
###-------------------------------------------------------------------------###


## This Node needs a reference to the enemy to access its functions and variables
func init(enemy: EnemyBase) -> void:
	self.enemy = enemy

## Plays the passed animation
func play_animation(anim: String = "Dance") -> void:
	model_animation_player.play(anim)
