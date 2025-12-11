extends Area2D
class_name HurtBox

# How much damage this HurtBox deals on contact.
@export var damage: int = 1


func _ready() -> void:
	# When this HurtBox's area overlaps another Area2D, get notified
	# via the `area_entered` signal.
	#
	# Connected to handler so every overlap runs AreaEntered().
	if not area_entered.is_connected(AreaEntered):
		area_entered.connect(AreaEntered)


func AreaEntered(area: Area2D) -> void:
	# Only interact with Areas that are HitBoxes.
	# This lets other Area2D nodes exist without being damaged by accident.
	if area is HitBox:
		var hitbox := area as HitBox
		hitbox.TakeDamage(damage)
