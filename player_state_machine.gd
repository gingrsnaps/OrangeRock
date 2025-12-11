extends Node
class_name PlayerStateMachine

# All State nodes attached as children of this node.
var states: Array[State] = []

# Previous and current active states.
var prev_state: State = null
var current_state: State = null


func _ready() -> void:
	# Start with processing disabled.
	process_mode = Node.PROCESS_MODE_DISABLED


func _process(delta: float) -> void:
	# No state yet -> nothing to process.
	if current_state == null:
		return

	# Let the current state run frame logic.
	var new_state: State = current_state.Process(delta)
	ChangeState(new_state)


func _physics_process(delta: float) -> void:
	if current_state == null:
		return

	var new_state: State = current_state.Physics(delta)
	ChangeState(new_state)


func _unhandled_input(event: InputEvent) -> void:
	if current_state == null:
		return

	var new_state: State = current_state.HandleInput(event)
	ChangeState(new_state)


func Initialize(player: Player) -> void:
	# Wire the single Player instance into the State base class.
	State.player = player

	# Collect all child nodes that are States.
	states.clear()
	for child in get_children():
		if child is State:
			states.append(child)

	if states.is_empty():
		push_warning("PlayerStateMachine has no State children. Add Idle, Walk, etc. as children.")
		return

	# Use the first State child as the starting state (usually Idle).
	current_state = states[0]
	current_state.Enter()

	# Now that we are initialized, allow this node to process.
	process_mode = Node.PROCESS_MODE_INHERIT


func ChangeState(new_state: State) -> void:
	# No change requested or same state -> do nothing.
	if new_state == null or new_state == current_state:
		return

	# Cleanly exit the old state if there is one.
	if current_state != null:
		current_state.Exit()

	# Switch and enter the new state.
	prev_state = current_state
	current_state = new_state
	current_state.Enter()
