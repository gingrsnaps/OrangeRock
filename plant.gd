extends Node2D
class_name Plant

func _ready() -> void:
	# Connect the HitBox's Damaged signal to this Plant's TakeDamage method.
	# This makes the plant react whenever something calls HitBox.TakeDamage().
	var hitbox := $HitBox
	if hitbox != null and not hitbox.Damaged.is_connected(TakeDamage):
		hitbox.Damaged.connect(TakeDamage)


func TakeDamage(_damage: int) -> void:
	# We don't care how much damage – any hit destroys the plant.
	queue_free()
