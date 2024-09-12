extends BaseStatusEffect


## 


###-------------------------------------------------------------------------###
##### Unique exported variables
###-------------------------------------------------------------------------###

## On this Status Effect's unique effect function call, a Timer is created.
## When this Timer reaches 0, the bearer of this Status Effect starts taking damage.
@export_range(0.1, 10.0, 0.1) var time_until_damage: float = 1.5

## Amount of damage the Entity is dealt every 'tick', as long as this Status Effect persists.
@export_range(0.5, 9999, 0.5) var damage_per_tick: float = 2.5

## How many damage 'tick' happen every second.
## Using this variable, damage ticks are spread evenly through every second.
@export_range(1, 999, 1) var ticks_per_second: int = 4


###-------------------------------------------------------------------------###
##### Unique function
###-------------------------------------------------------------------------###

func activate_unique_effect() -> void:
	print("effect activated")
	## Ask Globals to create a Timer and wait until it's done counting down.
	await Globals.get_tree().create_timer(time_until_damage).timeout
	
	## We will reuse the same Timer to await some time between damage 'ticks'.
	## The number of ticks is spread evenly through each second (1.0 here)
	var time_between_ticks: float = 1.0 / float(ticks_per_second)
	
	## Now that that Timer ran out,
	## the Entity that bears this Status Effect will begin taking damage.
	## The only way to stop this is to remove this Status Effect off of the Entity,
	## and remove its reference to the Entity - this Resource should destroy itself then.
	## NOTE: This Resource might not destroy itself if multiple instances of it exist?
	## NOTE: That's due to the way Resources are coded.
	while entity:
		entity.take_damage(damage_per_tick)
		
		## Create a new Timer that makes the ticks spaced out a little.
		await Globals.get_tree().create_timer(time_between_ticks).timeout
		
	
