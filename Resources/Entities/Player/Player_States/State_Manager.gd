extends Node

@export var starting_state: BasePlayerState

@export_group("All States")
#
@export var idle_state: BasePlayerState
@export var walk_state: BasePlayerState
@export var crouch_state: BasePlayerState
@export var jump_state: BasePlayerState
@export var fall_state: BasePlayerState
@export var stomp_state: BasePlayerState
##

var current_state: BasePlayerState


## The States need a reference to the Player to access its functions and variables
func init(player: Player) -> void:
	#Get each state and give it a reference to the Player and the StateManager, so that their
	#functions and variables can be accesses directly.
	for child in get_children():
		child.player = player
		child.state_manager = self
	
	#The state is set to the default state
	change_state(starting_state)


## State-changing function. Self-explainatory.
func change_state(new_state: BasePlayerState) -> void:
	if current_state:
		current_state.exit()
	
#	print("State now: ", current_state, "   State change: ", new_state)
	
	## Register what the current_state is, to add that to the new_state
	var previous_state: BasePlayerState = current_state
	
	## Switch to new_state
	current_state = new_state
	## Add the previous state to the new current_state
	current_state.previous_state = previous_state
	current_state.enter()


## The Player calls these functions, the state changes are handled as needed by States themselves
##
func physics_process(delta: float) -> void:
#	print(current_state)
#	if current_state.get("speed_multiplier"):
#		print(current_state.speed_multiplier)
	
	var new_state = current_state.physics_process(delta)
	if new_state:
		change_state(new_state)
#
func input(event: InputEvent) -> void:
	var new_state = current_state.input(event)
	if new_state:
		change_state(new_state)
#
func process(delta: float) -> void:
	var new_state = current_state.process(delta)
	if new_state:
		change_state(new_state)
