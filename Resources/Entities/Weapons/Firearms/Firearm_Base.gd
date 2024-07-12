extends Marker3D
class_name Firearm


###-------------------------------------------------------------------------###
##### Onready variables
###-------------------------------------------------------------------------###

## This node is created automaticaly when a Model is imported,
## if hte model file has animations attached to it 
@export var AnimPlayer: AnimationPlayer


###-------------------------------------------------------------------------###
##### Variable storage
###-------------------------------------------------------------------------###

var var1

## Called by the WeaponManager when this weapon is meant to be wielded/put away by the Player
func wield_weapon() -> void:
	self.visible = true
	AnimPlayer.play("pull_up")
#
func put_weapon_away() -> void:
	self.visible = false

## Called by the WeaponManager when the primary_action or the secondary_action buttons are pressed
func primary_action() -> void:
	print("called LMB")
	AnimPlayer.play("shoot")
#
func secondary_action() -> void:
	print("called RMB")
	AnimPlayer.play("shoot")
