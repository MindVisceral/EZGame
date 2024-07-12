class_name HitPointHandler
extends Node


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Exported")

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


## This Enemy responds to being hit.
func handle_hit_point(hit_point) -> void:
	pass
