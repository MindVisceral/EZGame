extends BaseEnemyState

###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("States")
#
@export var idle_state: BaseEnemyState


@export_group("Projectile")

@export var projectile: PackedScene


func enter() -> void:
	super.enter()
	
	## Reset the Navigation's path.
	enemy.Navigation.get_next_path_position()
	
	## Prepare attack
	attack()

func exit() -> void:
	super.exit()

func physics_process(delta: float) -> BaseEnemyState:
	
	## If the Enemy is still moving, make them decelerate down to zero
	## NOTE: Lerping enemy.velocity itself would also impact vertical (y) velocity,
	## NOTE: so we lerp X and Z separately instead.
	if !enemy.velocity.is_zero_approx():
		enemy.velocity.x = lerpf(enemy.velocity.x, 0, 100 * delta)
		enemy.velocity.z = lerpf(enemy.velocity.z, 0, 100 * delta)
	
	## Apply gravity (which is the Globals' gravity * multiplier)
	enemy.velocity.y -= enemy.gravity * BulletTime.time_scale * delta
	
	
	return null


## Prepare for attack
func attack() -> void:
	## Create new instance of the projectile
	var projectile_instance: ProjectileBase = projectile.instantiate()
	
	## Set global position, movement direction, etc.
	projectile_instance.global_position = %ProjectileMarker.global_position
	projectile_instance.firing_agent = enemy
	
	var projectile_target_position = enemy.target.global_position + Vector3(0, 0.8, 0)
	projectile_instance.direction = \
		(%ProjectileMarker.global_position.direction_to(projectile_target_position))
	
	## Finish instantiating the projectile
	get_tree().get_root().add_child(projectile_instance)
	
	## Attack is done, return to idle state
	enemy.States.change_state(idle_state)
