class_name Enemy
extends CharacterBody3D


###-------------------------------------------------------------------------###
##### Variables of Movement
###-------------------------------------------------------------------------###

### Movement variables
@export_group("Base movement")

## Enemy Gravity Multiplier
## The higher the number, the faster the Enemy will fall to the ground, and 
## the shorter will the jump be.
@export var gravity_multiplier: float = 0.2

## Enemy base speed
## All states use this base variable, instead modify the multiplier
## if you want to change movement speed.
@export var speed: float = 16

#HERE unneccessary
## Time it takes for the character to reach max speed
@export var acceleration: float = 8

#HERE unneccessary
## Time for the character to stop moving
@export var deceleration: float = 10



@export_group("Height") ## HERE - unneccessary

## Default Collider height in units
@export_range(0.1, 2, 0.1) var default_height: float = 1.6

## Default Collider width in units
@export_range(0.1, 1, 0.05) var default_width: float = 0.45


@export_group("Jump")

## Jump impulse height in units. Applied once on enter()
@export var jump_height: float = 25


###-------------------------------------------------------------------------###
##### Onready variables
###-------------------------------------------------------------------------###

@export_group("Exports")

## Enemy's gravity
@onready var gravity = Globals.global_gravity * gravity_multiplier

## Enemy's children. Check a child's Editor Description to learn what it's used for
@export var model: Node3D   ## A Node with a Skeleton3D, a Mesh, and an AnimationPlayer
@export var AnimPlayer: AnimationPlayer
@onready var States: EnemyStateManager = $Scripts/StateManager
@onready var stats: Stats = $Scripts/Stats
@onready var Hurt_Handler: HurtHandler = $Scripts/HurtHandler
@onready var Animation_Handler: AnimationHandler = $Scripts/AnimationHandler
@onready var Collider: CollisionShape3D = $CollisionShape3D
@onready var FloorCast: RayCast3D = $FloorCast
@onready var hurtbox: Area3D = $Hurtbox




var latest_DamageData: DamageData


###-------------------------------------------------------------------------###
##### Variable storage
###-------------------------------------------------------------------------###

## Flags
var is_dead: bool = false
var in_air: bool = false


## Direction of movement calculated in a State
var direction: Vector3 = Vector3()

###-------------------------------------------------------------------------###



func _ready() -> void:
	
	## Passes a reference of the Enemy Node to the states so that it can be used by them
	States.init(self)
	stats.init(self)
	Hurt_Handler.init(self)
	Animation_Handler.init(self)
	
	## Apply exported variables to the Enemy
	apply_exported()
	

###
func _physics_process(delta) -> void:
	if !is_dead:
		
		##States
		States.physics_process(delta)
		## Enemy's movement itself, dictated by the current_state in StateManager
		set_velocity(velocity)
		move_and_slide()
		velocity = velocity

func _process(delta) -> void:
	States.process(delta)


## On ready, apply exported variables like this: 
func apply_exported() -> void:
	
	## Instantly alter Collider dimensions
	Collider.shape.height = default_height
	Collider.shape.radius = default_width

func check_for_floor() -> bool:
	FloorCast.force_raycast_update()
#	print(FloorCast.is_colliding())
	return FloorCast.is_colliding()



func handle_hit(hit_point: Vector3) -> void:
	pass



## Enemy's current_health has reached 0
func death() -> void:
	
	print(self, " is dead!")
	queue_free()
