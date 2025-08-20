class_name BasePlayerState
extends Node

## Reference to the Player and the Player's StateManager, so
## that their functions and variables can be accessed directly
var player: Player
var state_manager: Node
var previous_state: BasePlayerState = self

## In case something
func initialize() -> void:
	pass

## Called on State start
func enter() -> void:
	pass

## Called on state exit
func exit() -> void:
	pass


## Reading Player input
func input(event: InputEvent) -> BasePlayerState:
	return null

func process(delta: float) -> BasePlayerState:
	return null

func physics_process(delta: float) -> BasePlayerState:
	return null
