extends Node3D

var in_range: bool = false

@onready var trauma_causer: TraumaCauser = $CameraTraumaCauser


func _process(delta: float) -> void:
	if in_range == true:
		trauma_causer.cause_trauma()
		
		## The shaking is only applied every .24 seconds
		in_range = false
		await get_tree().create_timer(0.24).timeout
		in_range = true



func _on_camera_trauma_causer_area_entered(area: Area3D) -> void:
	in_range = true

func _on_camera_trauma_causer_area_exited(area: Area3D) -> void:
	in_range = false
