class_name EnemyStateManager
extends Node

## The State in which the Enemy will start
@export var starting_state: BaseEnemyState
## All the possible states of the Enemy
@export var states: Array[BaseEnemyState] = []
## Holds current state
var current_state: BaseEnemyState


## The States need a reference to the enemy to access its functions and variables
func init(enemy: EnemyBase) -> void:
	#Get each state and give it a reference to the enemy and the StateManager, so that their
	#functions and variables can be accesses directly.
	for state in states:
		state.enemy = enemy
		state.state_manager = self
	
	#The state is set to the default state
	change_state(starting_state)


## State-changing function. Self-explainatory.
func change_state(new_state: BaseEnemyState) -> void:
	print("NEW ENEMY STATE: ", new_state)
	if current_state:
		current_state.exit()
	
#	print("State now: ", current_state, "   State change: ", new_state)
	
	## Register what the current_state is, to add that to the new_state
	var previous_state: BaseEnemyState = current_state
	
	## Switch to new_state
	current_state = new_state
	## Add the previous state to the new current_state
	current_state.previous_state = previous_state
	current_state.enter()


## The enemy calls these functions, the state changes are handled as needed by States themselves
##
func physics_process(delta: float) -> void:
	#print("CURRENT ENEMY STATE: ", current_state)
	
	var new_state = current_state.physics_process(delta)
	if new_state:
		change_state(new_state)
		
	
#
func process(delta: float) -> void:
	var new_state = current_state.process(delta)
	if new_state:
		change_state(new_state)
		
	
