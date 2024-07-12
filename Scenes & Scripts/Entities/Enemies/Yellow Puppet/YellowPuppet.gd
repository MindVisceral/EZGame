extends Enemy

func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	super(delta)

func _process(delta: float) -> void:
	super(delta)

func handle_hit(hit_point: Vector3) -> void:
	super(hit_point)
	
	print("WORKED?")
	States.change_state(States.states[1])
