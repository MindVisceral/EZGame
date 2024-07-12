class_name HurtHandler
extends Node


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Enemy-specific settings")

## Should the Enemy handle damage_value (ex. lose health on hit)?
@export var handle_damage_value: bool = true
## Should the Enemy handle hit_point (ex. check where the Hurtbox has been hit)?
@export var handle_hit_point: bool = false


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


## Receive the DamageData Resource and use its values
func receive_DamageData(damageData: DamageData) -> void:
	
	## The Stats Node will handle health lowering
	if handle_damage_value == true:
		## ...if the Stats Node exists
		if enemy.stats:
			enemy.stats.lower_health(damageData.damage_value)
	
	## This is Enemy-specific, so the Enemy must have a Script which can handle this data
	## If handle_hit_point is true, we assume the Enemy has such a Node as a child
	if handle_hit_point == true:
		## ...if the HitPointHandler exists
		enemy.Hit_Point_Handler.handle_hit_point(damageData.hit_point)
