class_name Interactable
extends Area3D

## Emmited when this Interactable node is looked at
signal focused()
## Emmited when this Interactable is not looked at anymore
signal unfocused()
## Emmited when an Entity wants to interact with the interactable_object (through this Interactable)
signal interact()
