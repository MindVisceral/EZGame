extends BaseEnemyState

###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Exported variables")

## How fast this Enemy rotates to face its movement direction (in radians - use PI)
@export_range(0.0, 2*PI, PI/90) var rotation_speed: float = PI

@export_group("States")
#
@export var idle_state: BaseEnemyState

func enter() -> void:
	super.enter()
	
	enemy.Animation_Handler.play_animation()

func exit() -> void:
	super.exit()
	

func physics_process(delta: float) -> BaseEnemyState:
	
	## Don't do pathing if Navigation isn't ready
	if NavigationServer3D.map_get_iteration_id(enemy.Navigation.get_navigation_map()) == 0:
		return null
		
	## Return to idle state if destination is reached
	if enemy.Navigation.is_navigation_finished():
		return idle_state
		
	
	## Get next position on the path to the Target
	var destination: Vector3 = enemy.Navigation.get_next_path_position()
	
	## Get movement direction from destination
	enemy.direction = enemy.global_position.direction_to(destination).normalized()
	
	## Apply velocity, take speed_multiplier and acceleration into account
	enemy.velocity = lerp(enemy.velocity, enemy.direction * enemy.speed, delta)
	
	## Apply gravity (which is the Globals' gravity * multiplier)
	enemy.velocity.y -= enemy.gravity * BulletTime.time_scale * delta
	
	
	return null
	

func process(delta: float) -> BaseEnemyState:
	## Rotate the Enemy along its Y axis to face the way its moving in.
	#
	## We want to use the built-in "angle()" function for Vector2s, so we convert this Vec3 to Vec2
	var temp_vec: Vector2 = Vector2(enemy.direction.x, enemy.direction.z)
	enemy.rotation.y = lerp_angle(enemy.rotation.y, (-temp_vec.angle() + PI/2), \
		rotation_speed * delta)
		
	
	return null
