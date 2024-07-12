class_name Interactable
extends Area3D

## Emmited when this Interactable node is looked at
signal focused()
## Emmited when this Interactable is not looked at anymore
signal unfocused()
## Emmited when an Entity wants to interact with the interactable_object (through this Interactable)
signal interact()

## When an Entity enters/exits the Range Area3D, we add/remove this Interactable node to/from
## that Entity's "interactables" Array
func _on_body_range_entered(body: Node3D) -> void:
	if body is Player:
		body.InteractionManager.interactables.append(self)
		print(body, " has entered ", self.owner, "'s Range!")
#
func _on_body_range_exited(body: Node3D) -> void:
	if body is Player:
		body.InteractionManager.interactables.erase(self)
		## We also emit the "unfocused" signal to avoid bugs
		## The Entity can't focus on the Interactable if it isn't within its reach, now can it?
		unfocused.emit()
		print(body, " has exited ", self.owner, "'s Range!")


## Outline system test
func _on_mouse_entered() -> void:
	focused.emit()
	print("FOCUSED")
#
func _on_mouse_exited() -> void:
	unfocused.emit()
	print("UNFOCUSED")


func _on_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouse:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			print("CLICKED")
