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
	
	## Get direction. You get what it is already.
	var direction: Vector3 = local_destination.normalized()
	
	## Make the Enemy move towards their destination. move_and_slide handled delta already...
	enemy.velocity = direction * enemy.speed
	
	## Apply gravity (which is the Globals' gravity * multiplier)
	enemy.velocity.y -= enemy.gravity * BulletTime.time_scale * delta
	
	
	## Rotate the Enemy along its Y axis to face the way its moving in.
	#
	## We want to use the built-in "angle()" function for Vector2s, so we convert this Vec3 to Vec2
	var temp_vec: Vector2 = Vector2(direction.x, direction.z)
	enemy.rotation.y = lerp_angle(enemy.rotation.y, (-temp_vec.angle() + PI/2), \
		rotation_speed * delta)
	
	
	return null
	
	
	
	### Set next destination's position on the Path to the final Target
	#var destination = enemy.Navigation.get_next_path_position()
	### Get the destination's position in local space?????
	#var local_destination = destination - enemy.global_position
	#
	### Get direction. You get what it is already.
	#var direction = local_destination.normalized()
	#
	### Make the Enemy move towards their destination. move_and_slide handled delta already...
	#enemy.velocity = direction * enemy.speed
	#
	### Apply gravity (which is the Globals' gravity * multiplier)
	#enemy.velocity.y -= enemy.gravity * BulletTime.time_scale * delta
