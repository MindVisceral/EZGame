extends Node

###-------------------------------------------------------------------------###
##### Variables and references
###-------------------------------------------------------------------------###

## Reference to the Player, so its functions and variables can be accessed directly
var player: Player

## Target Collider's height
var collider_height: float = 0.0
## Target Feet height
var feet_height: float = 0.0
## Target FloorCast height
var FloorCast_height: float = 0.0
## Target Head's height
var head_height: float = 0.0


###-------------------------------------------------------------------------###
##### Setup functions
###-------------------------------------------------------------------------###

## This Node needs a reference to the Player to access its functions and variables
func init(player: Player) -> void:
	self.player = player
	
	## Stop _physics_process() immediately for efficiency's sake
	set_physics_process(false)

## The Height is supposed to be altered over time, hence _physics_process()
## This is paused when it's not needed
func _physics_process(delta: float) -> void:
	
	## Separated into two for readability, and in case the Head is supposed to remain static
	alter_collider(delta)
	alter_Head(delta)
	
	## Once the desired heights are reached, stop calculations
	## used is_equal_approx, because the height never quite gets to the target height
	## Something to do with delta time? Doesn't seem important.
	if is_equal_approx(player.Collider.shape.height, self.collider_height) and \
		is_equal_approx(player.FeetCollider.position.y, self.feet_height) and \
		is_equal_approx(player.FloorCast.position.y, self.FloorCast_height) and \
		is_equal_approx(player.Head.position.y, self.head_height):
		## Stop this whole process, the target has been reached
		reset_alternator()



###-------------------------------------------------------------------------###
##### Initiation functions
###-------------------------------------------------------------------------###

## Use these three provided variables to alter the height through _physics_process
func alter_height(collider_height: float = 0.0, feet_height: float = 0.0, \
		FloorCast_height: float = 0.0, head_height: float = 0.0) -> void:
	
	print("ALTERNATOR ENABLED")
	## Start _physics_process() up again
	set_physics_process(true)
	
	## Set the target heights
	self.collider_height = collider_height
	self.feet_height = feet_height
	self.FloorCast_height = FloorCast_height
	self.head_height = head_height

## Reset the variables, wait for the next call of alter_height()
func reset_alternator() -> void:
	print("ALTERNATOR DISABLED")
	## Stop _physics_process() for efficiency's sake
	set_physics_process(false)
	
	## Reset the target heights
	self.collider_height = 0.0
	self.feet_height = 0.0
	self.FloorCast_height = 0.0
	self.head_height = 0.0


###-------------------------------------------------------------------------###
##### Executing functions
###-------------------------------------------------------------------------###

## Alters Collider's, FeetCollider's, and FloorCast's heights
func alter_collider(delta) -> void:
	#not head_check.is_colliding():
	#HERE add ^this^, can't allow to uncrouch when under something
	
	## lerp() the Collider's height towards target number
	player.Collider.shape.height = lerp(player.Collider.shape.height, self.collider_height, \
		delta * player.crouch_speed)
	
	
	##	lerp() the FeetCollider's height towards target number
	player.FeetCollider.position.y = lerp(player.FeetCollider.position.y, self.feet_height, \
		delta * player.crouch_speed)
	## lerp() the FloorCast's height towards target number
	player.FloorCast.position.y = lerp(player.FloorCast.position.y, self.FloorCast_height, \
		delta * player.crouch_speed)
	
	
	## Clamp the Collider's width, otherwise it gets altered too
	player.Collider.shape.radius = clamp(player.Collider.shape.radius, \
		player.default_width, player.default_width)

## Alters the Head's height
func alter_Head(delta) -> void:
	## lerp() the Head's height towards target number
	player.Head.position.y = lerp(player.Head.position.y, self.head_height, \
		delta * player.crouch_speed)
