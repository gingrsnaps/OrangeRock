extends CharacterBody2D
class_name Player

# Movement speed in pixels per second.
@export var move_speed: float = 100.0

# Last facing direction (cardinal only: LEFT/RIGHT/UP/DOWN).
var cardinal_direction: Vector2 = Vector2.DOWN

# Raw movement input for this frame.
var direction: Vector2 = Vector2.ZERO

# Optional debug/state label; not used by logic, but
# useful for debugging or on-screen UI.
var state_name: String = "idle"

# Cached node references.
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var state_machine: PlayerStateMachine = $StateMachine


func _ready() -> void:
	# Hook the player into its state machine.
	# This:
	#   - Sets State.player = self
	#   - Collects State children (Idle, Walk, etc.)
	#   - Enters the initial state (first child, typically Idle)
	state_machine.Initialize(self)


func _process(_delta: float) -> void:
	# Read movement input from actions.
	# Input Map should map "left/right/up/down" to:
	#   - WASD
	#   - controller D-pad
	#   - left controller joystick
	#
	# get_axis(negative, positive) == strength(positive) - strength(negative)
	direction.x = Input.get_axis("left", "right")
	direction.y = Input.get_axis("up", "down")

	# Normalize so diagonal movement isn't faster than straight movement.
	if direction.length() > 0.0:
		direction = direction.normalized()


func _physics_process(_delta: float) -> void:
	# The states are responsible for setting `velocity`.
	move_and_slide()


func SetDirection() -> bool:
	# Decide which cardinal direction we are facing based on current input.
	var new_dir: Vector2 = cardinal_direction

	# No movement input -> don't change direction.
	if direction == Vector2.ZERO:
		return false

	# Pick dominant axis so diagonals resolve to a cardinal direction.
	if abs(direction.x) > abs(direction.y):
		new_dir = Vector2.LEFT if direction.x < 0.0 else Vector2.RIGHT
	else:
		new_dir = Vector2.UP if direction.y < 0.0 else Vector2.DOWN

	if new_dir == cardinal_direction:
		return false

	# Apply new facing direction.
	cardinal_direction = new_dir

	# Flip sprite horizontally when facing LEFT.
	sprite_2d.scale.x = -1.0 if cardinal_direction == Vector2.LEFT else 1.0

	return true


func UpdateAnimation(state_str: String) -> void:
	# Helper used by states.
	#
	# `state_str` example values:
	#   "idle", "walk", "attack"
	state_name = state_str  # For debugging/GUI.

	var anim_name := state_str.capitalize() + "_" + AnimDirection()
	animation_player.play(anim_name)


func AnimDirection() -> String:
	# Return suffix to match animation names.
	if cardinal_direction == Vector2.DOWN:
		return "Down"
	elif cardinal_direction == Vector2.UP:
		return "Up"
	else:
		# LEFT and RIGHT both use the same "Side" animation.
		# Horizontal flip is handled by sprite_2d.scale.x.
		return "Side"
