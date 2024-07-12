extends Marker3D
class_name Firearm


###-------------------------------------------------------------------------###
##### Onready variables
###-------------------------------------------------------------------------###

## This node is created automaticaly when a Model is imported,
## if that Model had animations made in whatever program it was made in
@onready var AnimPlayer: AnimationPlayer = $ModelHolder/Model/AnimationPlayer


###-------------------------------------------------------------------------###
##### Variable storage
###-------------------------------------------------------------------------###

var var1

func _ready() -> void:
	pass

func fire() -> void:
	AnimPlayer.play("Shoot")
