extends BasePlayerState

@export_group("Movement")
#
## Time for the character to reach full speed
@export var acceleration: float = 8
## Time for the character to stop in place
@export var deceleration: float = 10
## Speed to be multiplied when active the ability
@export var speed_multiplier: float = 1.2


@export_group("States")
#
@export var idle_state: BasePlayerState
@export var walk_state: BasePlayerState
@export var jump_state: BasePlayerState


func enter() -> void:
	## Reset velocity, otherwise the momentum would persist
	player.velocity = Vector3.ZERO
	## Apply stomp impulse
	player.velocity.y -= player.stomp_strength
	
	super.enter()

func exit() -> void:
	super.exit()

## When a movement button is pressed, change to a corresponding State node
func input(event: InputEvent) -> BasePlayerState:
	
	return null

## Velocity equasions for this specific state and physics. Unrealated to player Inputs
func physics_process(delta) -> BasePlayerState:
	
	## Apply gravity (which is the Globals gravity * multiplier)
	player.velocity.y -= player.gravity
	
	## Check if the Player has reached the ground already
	if player.check_for_floor():
		return idle_state
	
	return null
