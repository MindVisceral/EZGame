extends BaseEnemyState

func enter() -> void:
	super.enter()
	#enemy.AnimPlayer.play("Idle ") ## Fucked up HERE, should be no space
	
	## Reset the Navigation's path.
	enemy.Navigation.get_next_path_position()
	
	## Unique to this State. Determine the rotation between this Enemy and their Target.
	get_rotation_to_target()

func exit() -> void:
	super.exit()

func physics_process(delta: float) -> BaseEnemyState:
	enemy.velocity = Vector3.ZERO
	
	return null

func get_rotation_to_target() -> void:
	pass
