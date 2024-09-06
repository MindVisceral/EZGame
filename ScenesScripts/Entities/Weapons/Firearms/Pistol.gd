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

## Called by the WeaponManager when this weapon is meant to be wielded by the Player
func wield_weapon() -> void:
	super.wield_weapon()
#
## Called by the WeaponManager when this weapon is meant to be put away by the Player
func put_weapon_away() -> void:
	super.put_weapon_away()


## Called when the primary_action button is pressed
func primary_action() -> void:
	super.primary_action()
#
## Called when the secondary_action button is pressed
func secondary_action() -> void:
	super.secondary_action()
