class_name HitPointHandler
## ^NOTE: This is a generic script, only meant to be used and extended when an Enemy needs
## to handle a hit_point Data point for any reason.
## NOTE: If you want to handle a hit_point, create a script which extends this class, attach it
## to the DamageDataHandler of the specific Enemy, and set it as DamageDataHandler's @exported
## variable. Everything should work from there.^
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
