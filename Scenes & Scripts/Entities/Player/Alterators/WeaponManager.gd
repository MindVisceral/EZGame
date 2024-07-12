class_name PlayerWeaponManager
extends Node

###-------------------------------------------------------------------------###
##### Variables and references
###-------------------------------------------------------------------------###


## Reference to the Player, so its functions and variables can be accessed directly
## Each weapon needs this reference
var player: Player
## This is the node which all the weapons are children of
## A reference to it is passed by the Player in the init() function in this script
var Firearms: Marker3D
#
## NOTE: Each position in the 'weapons' Array is considered a "slot";
## position 1 is Slot1, position 2 is Slot2, and so on
## In order to wield a weapon in any given spot, that spot's corresponding button must be pressed
#
## We hold all the weapons under the Firearms node in this Array
## NOTE: These elements are scenes! This Null represents the "no weapon wielded" weapon!
var weapons: Array = [null]
## The weapon that is currently wielded by the Player
## This simply holds the slot of the weapon that is currently wielded
## This is 0 by default, so it represents the Null weapon
var current_weapon_slot = 0
## This holds a direct reference to the weapon that is currently wielded
## through weapons[current_weapon_slot]
var current_weapon: FirearmBase


###-------------------------------------------------------------------------###
##### Setup functions
###-------------------------------------------------------------------------###

## This is ran once; when Player is _ready()
func init(player, firearms_node) -> void:
	self.player = player
	## We get a reference to the WeaponsHolder node. All the Weapons are stored under it
	self.Firearms = firearms_node
	
	## We update the 'weapons' Array, just in case
	update_weapons_array()
	
	## Now that we have all the weapons, we set each weapon's process to false
	## This is done so that the weapon can't fire while not wielded
	for weapon in weapons:
		if weapon != null:
			weapon.set_process(false)


###-------------------------------------------------------------------------###
##### Executing functions
###-------------------------------------------------------------------------###

## The Player calls these following functions every frame
#
##
func physics_process(delta: float) -> void:
	pass

## This code is ran only when a corresponding Event is found
func input(event: InputEvent) -> void:
	
	if current_weapon:
		current_weapon.input(event)
	
	#if Input.is_action_just_pressed("primary_action"):
		#call_weapon_primary_action()
	#if Input.is_action_just_pressed("secondary_action"):
		#call_weapon_secondary_action()
	
	## NOTE: Buttons 1-through-N correspond to a weapon's spot in the 'weapons' Array
	if Input.is_action_just_pressed("Spot1"):
		change_weapon(1)
	if Input.is_action_just_pressed("Spot2"):
		change_weapon(2)
	if Input.is_action_just_pressed("Spot3"):
		change_weapon(3)

func process(delta: float) -> void:
	pass




## NOTE: new_weapon is really just a number between 1 and N - it's a slot number
## This slot number corresponds to the index of a weapon in the 'weapons' Array
#
## Change current_weapon_slot to the provided new_weapon
## This disables the current_weapon - turns its logic and model off
## and then does the opposite to the new weapon, which becomes the new current_weapon
func change_weapon(new_weapon):
	## If new_weapon's slot is bigger than the number of weapons in the 'weapons' Array,
	## then we return, and we don't change the weapon at all.
	## There is no weapon to change to.
	if new_weapon >= (weapons.size()):
		return
	
	## If the new_weapon is the same slot as the current_weapon_slot,
	## we return and we don't change the weapon at all.
	## They are the same weapon.
	#
	## NOTE: This could also be rewritten to unequip the current_weapon!
	if new_weapon == current_weapon_slot:
		return
		
	
	## If the new_weapon is NOT the same as the current_weapon_slot...
	## They are different weapons!
	elif new_weapon != current_weapon_slot:
		print("success")
		## First, disable the old current_weapon
		disable_weapon(current_weapon_slot)
		## Second, change the current_weapon_slot to the new_weapon (also a slot)
		current_weapon_slot = new_weapon
		## Third, enable the new current_weapon
		enable_weapon(current_weapon_slot)


## Enables and reveals the weapon in the weapon_to_be_enabled slot
func enable_weapon(weapon_to_be_enabled) -> void:
	## Now we get the reference to the actual weapon scene
	current_weapon = weapons[weapon_to_be_enabled]
	
	## If this weapon isn't the Null weapon
	if current_weapon != null:
		## Make the weapon work
		current_weapon.set_process(true)
		## Wield the weapon - the weapon itself has this function in its script
		current_weapon.wield_weapon()

## Disables and hides the weapon in the weapon_to_be_disabled slot
func disable_weapon(weapon_to_be_disabled) -> void:
	## Now we get the reference to the actual weapon scene
	current_weapon = weapons[weapon_to_be_disabled]
	
	## If this weapon isn't the Null weapon
	if current_weapon != null:
		## Make the weapon not work - the weapon itself has this function in its script
		current_weapon.put_weapon_away()
		## Make the weapon not work anymore
		current_weapon.set_process(false)

## When the primary_action button is pressed, call the weapon's primary_action function
func call_weapon_primary_action() -> void:
	if current_weapon != null:
		current_weapon.primary_action()

## When the secondary_action button is pressed, call the weapon's secondary_action function
func call_weapon_secondary_action() -> void:
	if current_weapon != null:
		current_weapon.secondary_action()


## Ran once on init(), and whenever a weapon is picked up
func update_weapons_array() -> void:
	## Wipe the 'weapons' Array,
	weapons.clear()
	## Append the Null weapon (a lack of a wielded weapon)
	weapons.append(null)
	## and store all the weapons again
	for weapon in Firearms.get_children():
		weapons.append(weapon)
		weapon.player = self.player
		
		print("Firearm found: ", weapon)
	
	print("All weapons in Firearms: ", weapons)
