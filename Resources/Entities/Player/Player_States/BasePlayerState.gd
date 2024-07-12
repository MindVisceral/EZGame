class_name BasePlayerState
extends Node

#Not neccessary right now; it's for storing which animation should be played
#by a State, which is chosen in editor.
@export var animation_name: String

## Reference to the Player and the Player's StateManager, so
## that their functions and variables can be accessed directly
var player: Player
var state_manager: Node
var previous_state: BasePlayerState = self

func enter() -> void:
#	player.do_stuff()
# in the tutorial there was a 'play animation' call
	pass

func exit() -> void:
	pass


func input(event: InputEvent) -> BasePlayerState:
	return null

func process(delta: float) -> BasePlayerState:
	return null

func physics_process(delta: float) -> BasePlayerState:
	return null
