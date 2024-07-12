class_name HurtHandler
extends Node


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Exported Variables")


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


## Receive the DamageData Resource and use its values
func receive_DamageData(damageData: DamageData) -> void:
	## The Stats Node handles health lowering
	enemy.stats.lower_health(damageData.damage_value)
	## 
	enemy.handle_hit(damageData.hit_point)
