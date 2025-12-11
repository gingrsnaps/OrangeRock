extends Node
class_name State

static var player: Player


# Called once when this state becomes the active state.
# Override in child classes.
func Enter() -> void:
	pass


# Called once when this state stops being the active state.
# Override in child classes.
func Exit() -> void:
	pass


# Per-frame (non-physics) logic.
# Return:
#   - null        -> remain in this state
#   - another State -> change to that state
func Process(_delta: float) -> State:
	return null


# Physics-step logic.
# Called from PlayerStateMachine._physics_process().
# Same return contract as Process().
func Physics(_delta: float) -> State:
	return null


# Handle input while this state is active.
# Usually called from PlayerStateMachine._unhandled_input().
# Same return contract as Process().
func HandleInput(_event: InputEvent) -> State:
	return null
