class_name BaseEnemyState
extends Node

## All the states that can be changed to from this state
@export var states: Array[BaseEnemyState] = []

## Reference to the Enemy and the Enemy's StateManager, so
## that their functions and variables can be accessed directly
var enemy: EnemyBase
var state_manager: Node
var previous_state: BaseEnemyState = self

func enter() -> void:
	pass

func exit() -> void:
	pass


func process(delta: float) -> BaseEnemyState:
	return null

func physics_process(delta: float) -> BaseEnemyState:
	return null
