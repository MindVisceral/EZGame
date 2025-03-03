extends BaseEnemyState

###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Exported variables")

## How fast this Enemy rotates to face its movement direction (in radians - use PI)
@export_range(0.0, 2*PI, PI/90) var rotation_speed: float = PI


func enter() -> void:
	super.enter()
	#enemy.AnimPlayer.play("Idle ") ## Fucked up HERE, should be no space
	

func exit() -> void:
	super.exit()


func physics_process(delta: float) -> BaseEnemyState:
	
	## Set next destination's position on the Path to the final Target
	var destination: Vector3 = enemy.Navigation.get_next_path_position()
	## Get the destination's position in local space?????
	var local_destination: Vector3 = destination - enemy.global_position
	#print(local_destination, " - manual")
	#local_destination = enemy.to_local(destination)
	#print(local_destination, " - functional")
	
	## Get direction. You get what it is already.
	enemy.direction = local_destination.normalized()
	#print("direction normalized: ", enemy.direction)
	
	## Apply velocity, take speed_multiplier and acceleration into account
	## NOTE: Lerping enemy.velocity itself would also impact vertical (y) velocity,
	## NOTE: so we lerp X and Z separately instead.
	enemy.velocity.x = lerpf(enemy.velocity.x, \
		(enemy.direction.x * enemy.speed), 8.0 * delta)
	enemy.velocity.z = lerpf(enemy.velocity.z, \
		(enemy.direction.z * enemy.speed), 8.0 * delta)
	
	#print("global pos: ", enemy.global_position, "    destination: ", destination)
	
	#if enemy.global_position.is_equal_approx(destination):
		#print("REACHED IT")
		#
	
	#print("enemy velocity: ", enemy.velocity)
	
	## Apply gravity (which is the Globals' gravity * multiplier)
	#enemy.velocity.y -= enemy.gravity * BulletTime.time_scale * delta
	
	
	return null
	

func process(delta: float) -> BaseEnemyState:
	## Rotate the Enemy along its Y axis to face the way its moving in.
	#
	## We want to use the built-in "angle()" function for Vector2s, so we convert this Vec3 to Vec2
	var temp_vec: Vector2 = Vector2(enemy.direction.x, enemy.direction.z)
	enemy.rotation.y = lerp_angle(enemy.rotation.y, (-temp_vec.angle() + PI/2), \
		rotation_speed * delta)
		
	
	return null
