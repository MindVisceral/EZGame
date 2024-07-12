class_name EnemyBase
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
@export var States: EnemyStateManager
@export var stats: Stats
@export var DamageData_Handler: DamageDataHandler
@export var Animation_Handler: AnimationHandler
@export var Collider: CollisionShape3D
@export var FloorCast: RayCast3D
@export var hurtbox: Hurtbox


###-------------------------------------------------------------------------###
##### Variable storage
###-------------------------------------------------------------------------###

## Flags
var is_dead: bool = false
var in_air: bool = false


## Direction of movement calculated in a State
var direction: Vector3 = Vector3()

## The most recent DamageData packed that has been received
var latest_DamageData: DamageData


###-------------------------------------------------------------------------###



func _ready() -> void:
	
	## Passes a reference of the Enemy Node to the states so that it can be used by them
	States.init(self)
	stats.init(self)
	DamageData_Handler.init(self)
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


## On ready, apply exported variables.
func apply_exported() -> void:
	## Instantly alter Collider dimensions
	Collider.shape.height = default_height
	Collider.shape.radius = default_width

func check_for_floor() -> bool:
	FloorCast.force_raycast_update()
#	print(FloorCast.is_colliding())
	return FloorCast.is_colliding()


## Receive damage data from the Hurtbox, store it, and send it off to
## the Hurthandler for it to interpret it
## and pass each data point on to the Node that can handle it
func receive_DamageData(damageData: DamageData) -> void:
	latest_DamageData = damageData
	DamageData_Handler.receive_DamageData(damageData)



## Enemy's current_health has reached 0
func death() -> void:
	
	print(self, " is dead!")
	queue_free()
