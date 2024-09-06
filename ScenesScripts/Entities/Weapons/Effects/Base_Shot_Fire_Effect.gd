extends Node3D
## NOTE: This Node is queue_free()-d by the AnimationPlayer when the animation is finished

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
