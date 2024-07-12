## @tool because we use configuration warnings for this node
@tool

extends MeshInstance3D

## The text String which this MeshInstace will take form of through a TextMesh
@export var text: String:
	get:
		return text
	set(value):
		text = value
		update_text()
		if Engine.is_editor_hint():
			update_configuration_warnings()

## The text's colour
@export var text_albedo: Color = Color("ffffff"):
	get:
		return text_albedo
	set(value):
		text_albedo = value
		update_albedo()


func _ready() -> void:
	update_text()
	update_albedo()


## Update text String
func update_text() -> void:
	mesh.text = text

## Update text colour
func update_albedo() -> void:
	self.mesh.material.albedo_color = text_albedo

func _get_configuration_warnings() -> PackedStringArray:
	if text == null:
		return ["No text has been entered!"]
	return []
