extends Node

###-------------------------------------------------------------------------###
##### Variables and references
###-------------------------------------------------------------------------###

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
var current_weapon = 0


###-------------------------------------------------------------------------###
##### Setup functions
###-------------------------------------------------------------------------###

## This is ran once; when Player is _ready()
func init(firearms_node) -> void:
	## We get a reference to the WeaponsHolder node. All the Weapons are stored under it
	self.Firearms = firearms_node
	
	## We update the 'weapons' Array, just in case
	update_weapons_array()


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
	
	## NOTE: Buttons 1-through-N correspond to a weapon's spot in the 'weapons' Array
#	if not current_weapon.is_busy():
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
## Change current_weapon to the provided new_weapon
## This disables the current_weapon - turns its logic and model off
## and then does the opposite to the new_weapon, which becomes the new current_weapon
func change_weapon(new_weapon):
#	print(new_weapon)
#	print("Current weapon: ", weapons[current_weapon])
#	print("All weapons: ", weapons)
#	print(weapons.find(current_weapon))
	
	## If new_weapon's slot is bigger than the number of weapons in the 'weapons' Array,
	## then we return, and we don't change the weapon at all.
	## There is no weapon to change to.
	if new_weapon >= (weapons.size()):
		return
	
	## If the new_weapon is in the same slot as the current_weapon,
	## we return and we don't change the weapon at all.
	## They are the same weapon.
	#
	## NOTE: This could also be rewritten to unequip the current_weapon!
	if new_weapon == current_weapon:
		return
		
	
	## If the new_weapon is NOT the same as the current_weapon...
	## They are different weapons!
	elif new_weapon != current_weapon:
		print("success")
		## First, disable the old current_weapon
		disable_weapon(current_weapon)
		## Second, change the current_weapon (slot) to the new_weapon (also a slot)
		current_weapon = new_weapon
		## Third, enable the new current_weapon
		enable_weapon(current_weapon)


func enable_weapon(weapon_to_be_enabled) -> void:
	## Now we get the reference to the actual weapon (as a scene)
	var weapon: Firearm = weapons[weapon_to_be_enabled]
	
	## If this weapon isn't the Null weapon
	if weapon != null:
		## Make the weapon work
		weapon.set_process(true)
		## Make it show up
		weapon.visible = true

func disable_weapon(weapon_to_be_disabled) -> void:
	## Now we get the reference to the actual weapon (as a scene)
	var weapon: Firearm = weapons[weapon_to_be_disabled]
	
	## If this weapon isn't the Null weapon
	if weapon != null:
		## Make the weapon not work
		weapon.set_process(false)
		## Make it invisible
		weapon.visible = false




## Ran once on init(), and whenever a weapon is picked up
func update_weapons_array() -> void:
	## Wipe the 'weapons' Array,
	weapons.clear()
	## Append the Null weapon (a lack of a wielded weapon)
	weapons.append(null)
	## and store all the weapons again
	for child in Firearms.get_children():
		weapons.append(child)
		
		print("Firearm found: ", child)
	
	print("All weapons in Firearms: ", weapons)
