class_name Interactable
extends Area3D

## The object which this Element is in charge of
@export var interactable_object: Node3D


## When an Entity enters/exits the Range Area3D, we add/remove the interactable_object to/from
## that Entity's "interactables" Array
func _on_body_range_entered(body: Node3D) -> void:
	if body is Player:
		body.InteractionManager.interactables.append(interactable_object)
		print(body, " has entered ", interactable_object, "'s Range!")
#
func _on_body_range_exited(body: Node3D) -> void:
	if body is Player:
		body.InteractionManager.interactables.erase(interactable_object)
		print(body, " has exited ", interactable_object, "'s Range!")
