extends BaseEnemyState

###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("States")
#
@export var idle_state: BaseEnemyState



func enter() -> void:
	super.enter()
	
	## Reset the Navigation's path.
	enemy.Navigation.get_next_path_position()
	
	## Prepare attack
	prepare_attack()

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
func prepare_attack() -> void:
	
	
	## Attack is fully prepared...
	release_attack()

## Release the attack, get out of attack state
func release_attack() -> void:
	
	
	## Attack is done, return to idle state
	enemy.States.change_state(idle_state)
