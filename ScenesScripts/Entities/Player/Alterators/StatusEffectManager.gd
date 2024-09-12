class_name PlayerStatusEffectManager
extends Node


## The Player may be under effect of various Status Effects, like freezing while in Water.
## This Manager takes care of Status Effects.


###-------------------------------------------------------------------------###
##### Exported variables and references
###-------------------------------------------------------------------------###

## Reference to the Player, so its functions and variables can be accessed directly
var player: Player

## This Array holds all Status Effects the Player is under right now.
@export var status_effects: Array[BaseStatusEffect] = []


###-------------------------------------------------------------------------###
##### Regular variables
###-------------------------------------------------------------------------###

## Every time the Player gains or loses a Status Effect, this signal is fired.
signal player_status_effects_changed


###-------------------------------------------------------------------------###
##### Setup
###-------------------------------------------------------------------------###

## This Node needs a reference to the Player to access its functions and variables
func init(player: Player) -> void:
	self.player = player
	


###-------------------------------------------------------------------------###
##### Core functions
###-------------------------------------------------------------------------###

## When something wants the Player to be under a Status Effect,
## it must pass that Status Effect through this function.
func add_status_effect(status_effect: BaseStatusEffect) -> void:
	## There may only be one kind of a Status Effect applied to the Player at one time;
	## ex. the Player can have only one "Cold" Status Effect, and adding more of them
	## does nothing.
	for status in status_effects:
		## We compare this new status_effect's name to
		## names of all status_effects in 'status_effects' Array,
		## and if one such Status already exists, then we don't accept it.
		if status_effect.status_effect_name == status.status_effect_name:
			return
			
		
	## A copy of this status_effect couldn't be found in the status_effects Array,
	## so we can safely add it to that Array.
	status_effects.append(status_effect)
	## And pass on a reference to the Player. It will need that.
	status_effect.entity = player
	## And now we maycall this new status_effect's unique effect function.
	status_effect.activate_unique_effect()
	
	player_status_effects_changed.emit()

## Some Status Effect don't expire on their own, so they must be removed manually.
func remove_status_effect(status_effect: BaseStatusEffect) -> void:
	print("Player is ", status_effect.status_effect_name, " no longer!")
	
	status_effect.entity = null
	status_effects.erase(status_effect)
	
	print("status_effects Array: ", status_effects)
	
	player_status_effects_changed.emit()

## Some scripts, like the UIManager, need to know if there are any Status Effect on the Player.
## Returns true if there are any Status Effects connected to the Player.
func check_for_status_effects() -> bool:
	return !status_effects.is_empty()
	
