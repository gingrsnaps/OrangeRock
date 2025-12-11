extends State
class_name State_Walk

# Reference to the Idle state node (sibling under StateMachine).
@onready var idle: State_Idle = $"../Idle"
@onready var attack: State_Attack = $"../Attack"


func Enter() -> void:
	# Immediately play walk animation in the current facing direction.
	# Direction itself may be updated on the next Physics() call.
	player.UpdateAnimation("walk")


func Exit() -> void:
	pass


func Process(_delta: float) -> State:
	# Movement and transitions are handled in Physics().
	return null


func Physics(_delta: float) -> State:
	# No input? Stop and go back to Idle.
	if player.direction == Vector2.ZERO:
		player.velocity = Vector2.ZERO
		return idle

	# Still have input: move the player.
	player.velocity = player.direction * player.move_speed

	# Update facing and animation when direction changes.
	if player.SetDirection():
		player.UpdateAnimation("walk")

	return null


func HandleInput(_event: InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		return attack
	return null
