class_name Water
extends Area3D


## The Player must avoid all Water, because it damages them.


###-------------------------------------------------------------------------###
##### Variables
###-------------------------------------------------------------------------###

## Water grants the Player with the "Cold" Status Effect
@onready var status_effect: BaseStatusEffect = \
	preload("res://ScenesScripts/Entities/StatusEffects/StatusEffect_cold.tres")


###-------------------------------------------------------------------------###
##### Setup
###-------------------------------------------------------------------------###

## Since func_godot doesn't connect built-in signals automatically,
## we must do it manually.
func _ready() -> void:
	self.connect("area_entered", _on_area_entered)
	self.connect("area_exited", _on_area_exited)
	
	self.connect("body_entered", _on_body_entered)
	self.connect("body_exited", _on_body_exited)
	


###-------------------------------------------------------------------------###
##### Areas entering/exiting Water
###-------------------------------------------------------------------------###

## When an Area enters this Water...
func _on_area_entered(area: Area3D) -> void:
	pass
	

## When an Area exits this Water...
func _on_area_exited(area: Area3D) -> void:
	pass


###-------------------------------------------------------------------------###
##### Bodies entering/exiting Water
###-------------------------------------------------------------------------###

## When a body enters this Water...
func _on_body_entered(body: Node3D) -> void:
	## We're only really looking for the Player and Enemies.
	if body is Player:
		print("Player entered!")
		body.StatusEffects.add_status_effect(status_effect)
	

## When a body exits this Water...
func _on_body_exited(body: Node3D) -> void:
	## We're only really looking for the Player and Enemies.
	if body is Player:
		print("Player exited!")
		body.StatusEffects.remove_status_effect(status_effect)
	
