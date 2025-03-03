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
	
	## If the Enemy is still moving, make them decelerate down to zero
	## NOTE: Lerping enemy.velocity itself would also impact vertical (y) velocity,
	## NOTE: so we lerp X and Z separately instead.
	enemy.velocity.x = lerpf(enemy.velocity.x, (enemy.direction.x * enemy.speed), delta)
	enemy.velocity.z = lerpf(enemy.velocity.z, (enemy.direction.z * enemy.speed), delta)
	
	## Apply gravity (which is the Globals' gravity * multiplier)
	enemy.velocity.y -= enemy.gravity * BulletTime.time_scale * delta
	
	
	return null

func get_rotation_to_target() -> void:
	pass
