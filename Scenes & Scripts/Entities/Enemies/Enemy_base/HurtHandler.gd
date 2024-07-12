class_name HurtHandler
extends Node


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Exported Variables")

## Should the Enemy handle damage_value (ex. lose health on hit)?
@export var handle_damage_value: bool = true
## Should the Enemy handle hit_point (ex. check where on the Hurtbox it has been hit)?
@export var handle_hit_point: bool = false


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
	enemy.latest_DamageData = damageData
	
	
	## The Stats Node handles health lowering
	if handle_damage_value == true:
		enemy.stats.lower_health(damageData.damage_value)
	
	## This is Enemy-specific, so the Enemy must have a Script which can handle this data
	## If handle_hit_point is true, we assume the Enemy has such a Node as a child
	if handle_hit_point == true:
		enemy.handle_hit(damageData.hit_point)
