extends Node2D
class_name PlayerInteractionsHost

# Reference to the Player node (assumed to be the parent).
@onready var player: Player = $".."


func _ready() -> void:
	# Safely connect to the Player's DirectionChanged signal.
	# This avoids duplicate connections if the scene is reloaded.
	if player != null and not player.DirectionChanged.is_connected(UpdateDirection):
		player.DirectionChanged.connect(UpdateDirection)


func UpdateDirection(new_direction: Vector2) -> void:
	# Rotate this node based on the player's facing direction.
	# Child nodes (like HurtBox) will rotate with it.
	match new_direction:
		Vector2.DOWN:
			rotation_degrees = 0
		Vector2.UP:
			rotation_degrees = 180
		Vector2.LEFT:
			rotation_degrees = 90
		Vector2.RIGHT:
			rotation_degrees = -90
		_:
			# Fallback if something unexpected is passed in.
			rotation_degrees = 0
