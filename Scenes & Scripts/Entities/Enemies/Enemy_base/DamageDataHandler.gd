class_name DamageDataHandler
extends Node


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Enemy-specific settings")

## Should this Enemy handle damage_value (ex. lose health on hit)?
@export var handle_damage_value: bool = true
## Should this Enemy handle hit_point (ex. check where the Hurtbox has been hit)?
@export var handle_hit_point: bool = false

## Enemy-specific HitPointHandler. This varies between enemies, because each one can respond
## differently to being hit.
@export var hit_point_handler: HitPointHandler


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
	
	## If HitPointHandler is present...
	if hit_point_handler:
		hit_point_handler.enemy = enemy


## Receive the DamageData Resource, read its values, pass them onto Nodes that can handle them.
func receive_DamageData(damageData: DamageData) -> void:
	
	## The Stats Node will handle health lowering
	if handle_damage_value == true:
		## ...if the Stats Node exists
		if enemy.stats:
			enemy.stats.lower_health(damageData.damage_value)
	
	## This is Enemy-specific, so the Enemy must have a Script which can handle this data.
	## NOTE: That script MUST extend HitPointHandler class to work!
	## If handle_hit_point is true, we assume the Enemy has such a Node as a child
	if handle_hit_point == true:
		## ...if the HitPointHandler exists
		if hit_point_handler:
			hit_point_handler.handle_hit_point(damageData.hit_point)
