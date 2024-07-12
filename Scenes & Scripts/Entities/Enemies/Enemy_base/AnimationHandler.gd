class_name AnimationHandler
extends Node


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Exported Animations")

###-------------------------------------------------------------------------###
##### Regular variables
###-------------------------------------------------------------------------###

## Reference to the Enemy so that their functions and variables can be accessed directly
var enemy: Enemy


###-------------------------------------------------------------------------###
##### Functions
###-------------------------------------------------------------------------###


## This Node needs a reference to the enemy to access its functions and variables
func init(enemy: Enemy) -> void:
	self.enemy = enemy
