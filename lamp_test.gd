extends CSGBox3D

@onready var light: OmniLight3D = $OmniLight3D


@export var is_turned_on: bool = true


func interact() -> void:
	## Toggles omnilight
	if is_turned_on == true:
		is_turned_on = false
		light.hide()
	else:
		is_turned_on = true
		light.show()
