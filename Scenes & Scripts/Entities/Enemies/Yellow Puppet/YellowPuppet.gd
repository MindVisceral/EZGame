extends EnemyBase

func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	super(delta)

func _process(delta: float) -> void:
	super(delta)

func receive_DamageData(damageData: DamageData) -> void:
	super(damageData)
	
	States.change_state(States.states[1])
