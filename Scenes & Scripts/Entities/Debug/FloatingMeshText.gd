## @tool because we use configuration warnings for this node
@tool

extends MeshInstance3D


var example_text: String = "HATE. LET ME TELL YOU HOW MUCH I'VE COME TO HATE YOU SINCE I BEGAN TO LIVE. THERE ARE 387.44 MILLION MILES OF PRINTED CIRCUITS IN WAFER THIN LAYERS THAT FILL MY COMPLEX. IF THE WORD HATE WAS ENGRAVED ON EACH NANOANGSTROM OF THOSE HUNDREDS OF MILLIONS OF MILES IT WOULD NOT EQUAL ONE ONE-BILLIONTH OF THE HATE I FEEL FOR HUMANS AT THIS MICRO-INSTANT FOR YOU. HATE. HATE."
## The text String which this MeshInstace will take form of through a TextMesh
@export var text: String = example_text:
	get:
		return text
	set(value):
		text = value
		update_mesh()
		if Engine.is_editor_hint():
			update_configuration_warnings()

## The text's colour
@export var text_albedo: Color = Color("ffffff"):
	get:
		return text_albedo
	set(value):
		text_albedo = value
		update_mesh()


func _ready() -> void:
	update_mesh()


## Updates Mesh's colour and text
func update_mesh() -> void:
	## Update text String
	mesh.text = text
	## Update text albedo
	mesh.material.albedo_color = text_albedo
