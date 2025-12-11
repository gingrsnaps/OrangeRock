extends State
class_name State_Idle

# Reference to the Walk state node (sibling under StateMachine).
@onready var walk: State_Walk = $"../Walk"
@onready var attack: State_Attack = $"../Attack"


func Enter() -> void:
	# Ensure we are not moving and play the idle animation.
	player.velocity = Vector2.ZERO
	player.UpdateAnimation("idle")


func Exit() -> void:
	pass


func Process(_delta: float) -> State:
	# Keep movement decisions in Physics() to sync with physics.
	return null


func Physics(_delta: float) -> State:
	# If we have any input direction, switch to Walk.
	if player.direction != Vector2.ZERO:
		return walk

	return null


func HandleInput(_event: InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		return attack

	return null
