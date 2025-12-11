extends Area2D
class_name HitBox

# Emitted when this hitbox is told to deal damage.
# `damage` is the damage amount to apply.
signal Damaged(damage: int)


func TakeDamage(damage: int) -> void:
	# Debug log to help during development
	print("HitBox.TakeDamage:", damage)

	# Broadcast the damage value to any connected listeners.
	Damaged.emit(damage)
