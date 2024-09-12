class_name BaseStatusEffect
extends Resource


###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

## Only Entities can bear Status Effects. We need a reference to the Entity tha bears this Effect.
var entity: CharacterBody3D


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

## What's the name of this Status Effect?
@export var status_effect_name: String


###-------------------------------------------------------------------------###
##### Status Effect functions
###-------------------------------------------------------------------------###

## Each Status Effect does some unique thing.
## This function is called by the Entity's StatusEffectManager when a Statue Effect is activated.
func activate_unique_effect() -> void:
	pass
