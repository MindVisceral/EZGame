class_name EnemyAIBase
extends Node


## This is base Enemy AI. It decides what the Enemy should do at any moment.
## Every Enemy AI is unique to each Enemy, this is just a base that takes care of base stuff that
## almost every AI needs, like navigation and targetting.


###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

@export_group("References")

##



###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Exported variables")

## AI is only updated once every >this< amount of time (in milliseconds, 1000ms = 1 second)
@export_range(1, 5000, 0.9) var time_between_AI_updates: int = 200


###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

## Reference to the Enemy so that their functions and variables can be accessed directly
var enemy: EnemyBase

## Reference to the Enemy's AI Handler.
var AI_handler: AIHandler


###-------------------------------------------------------------------------###
##### Regular variables
###-------------------------------------------------------------------------###

## Used to keep track of time between AI updates with Time.get_ticks_msec()
var time_at_last_AI_update: int = 0


###-------------------------------------------------------------------------###
##### Setup
###-------------------------------------------------------------------------###

## This Node needs a reference to the enemy to access its functions and variables
func init(enemy: EnemyBase, AI_handler: AIHandler) -> void:
	self.enemy = enemy
	self.AI_handler = AI_handler
	

## This is a dummy function. It's here, in the BaseAI script, because it's called by the AIHandler,
## but its contents are unique to each AI.
func setup() -> void:
	print("Default BaseAI setup() function called!")
