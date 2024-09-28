class_name AIHandler
extends Node


###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

@export_group("References")

## Reference to this specific Enemy's unique AI.
@export var enemy_AI: EnemyAIBase


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Exported variables")


###-------------------------------------------------------------------------###
##### Regular variables
###-------------------------------------------------------------------------###

## Reference to the Enemy so that their functions and variables can be accessed directly
var enemy: EnemyBase


###-------------------------------------------------------------------------###
##### Functions
###-------------------------------------------------------------------------###

## This Node needs a reference to the Enemy to access its functions and variables
func init(enemy: EnemyBase) -> void:
	self.enemy = enemy
	
	
	## The Enemy AI itself also needs a reference to the Enemy, and a reference to this AI Handler
	enemy_AI.init(enemy, self)
	## And call the AI's unique setup function.
	enemy_AI.setup()

## Simply uses NavigationAgent3D to find the shortest path to the passed end_point.
func find_path_to(end_point: Vector3) -> void:
	## Set the Enemy's Navigation's target_position to the passed end_point
	enemy.Navigation.set_target_position(end_point)
	

## Reset pathfinding, it's not needed right now.
func reset_path() -> void:
	enemy.Navigation.set_target_position(enemy.global_position)
	print(enemy.Navigation)
