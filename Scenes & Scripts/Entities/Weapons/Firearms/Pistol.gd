extends FirearmHitscan
## ^NOTE: Extends FirearmHitscan! Check that scene/script for more if you can't find something here!^
class_name FirearmsPistols

###-------------------------------------------------------------------------###
##### Pistol-specific onready variables
###-------------------------------------------------------------------------###


###-------------------------------------------------------------------------###
##### Pistol-specific variable storage
###-------------------------------------------------------------------------###


###-------------------------------------------------------------------------###
##### Pistol-specific Firearm functions
###-------------------------------------------------------------------------###

## NOTE: The following functions are repeated from the FirearmBase and FirearmHitscan classes!

#func input(event: InputEvent) -> void:
	#super.input(event)

## Called by the WeaponManager when this weapon is meant to be wielded/put away by the Player
func wield_weapon() -> void:
	super.wield_weapon()
#
func put_weapon_away() -> void:
	super.put_weapon_away()


## Called by the WeaponManager when the primary_action or the secondary_action buttons are pressed
func primary_action() -> void:
	super.primary_action()
#
func secondary_action() -> void:
	super.secondary_action()
