extends CSGBox3D

@onready var light: OmniLight3D = $OmniLight3D


@export var is_turned_on: bool = true
var is_focused: bool = false


## Toggle on and off when interacted with
func _on_interact() -> void:
	## Toggles omnilight
	if is_turned_on == true:
		is_turned_on = false
		light.hide()
	else:
		is_turned_on = true
		light.show()


## 
func _on_focused() -> void:
	is_focused = true
	print("focused on: ", self)
	switch_shader()
#
func _on_unfocused() -> void:
	is_focused = false
	print("unfocused from: ", self)
	switch_shader()


func switch_shader() -> void:
	if is_focused == true:
		material.next_pass.set_shader_parameter("border_width", 0.05)
	else:
		material.next_pass.set_shader_parameter("border_width", 0.0)
