extends State
class_name State_Attack

# True while the attack animation is playing.
var attacking: bool = false

# Global cooldown tracking (shared by all instances of this state).
# Time is stored in milliseconds from Time.get_ticks_msec().
static var _next_attack_allowed_time_ms: int = 0

# Attack SFX and deceleration tuning.
@export var attack_sound: AudioStream
@export_range(1.0, 20.0, 0.5) var decelerate_speed: float = 5.0

# Cooldown between attacks in milliseconds.
@export var attack_cooldown_ms: int = 10

# Sibling states under the StateMachine node.
@onready var idle: State_Idle = $"../Idle"
@onready var walk: State_Walk = $"../Walk"

# Main animation player on the player (Idle/Walk/Attack animations).
@onready var body_anim: AnimationPlayer = $"../../AnimationPlayer"

# Secondary animation player for the slash sprite.
@onready var effect_anim: AnimationPlayer = $"../../Sprite2D/AttackEffectSprite/AnimationPlayer"

# Audio player for attack sound.
@onready var audio: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"


func Enter() -> void:
	# Check global cooldown before starting a new attack.
	var now_ms: int = Time.get_ticks_msec()
	if now_ms < _next_attack_allowed_time_ms:
		# Still in cooldown -> do NOT start a new attack.
		# Leave `attacking` as false so Process() will immediately
		# return us to Idle/Walk on the next frame.
		attacking = false
		return

	# Start a real attack.
	attacking = true

	# Update facing direction from current input if any.
	if player.direction != Vector2.ZERO:
		player.SetDirection()

	# Play the body attack animation.
	player.UpdateAnimation("attack")

	# Play the attack effect animation.
	# Effect animations are: attack_down, attack_side, attack_up.
	var effect_name: String = "attack_" + player.AnimDirection().to_lower()
	if effect_anim != null and effect_anim.has_animation(effect_name):
		effect_anim.play(effect_name)

	# Play attack sound if one is assigned.
	if attack_sound:
		audio.stream = attack_sound
		audio.pitch_scale = randf_range(0.9, 1.1)
		audio.play()

	# When the main body attack animation finishes, end the attack.
	if not body_anim.animation_finished.is_connected(_on_body_animation_finished):
		body_anim.animation_finished.connect(_on_body_animation_finished)


func Exit() -> void:
	# Clean signal connection so it doesn't stack up on re-enter.
	if body_anim.animation_finished.is_connected(_on_body_animation_finished):
		body_anim.animation_finished.disconnect(_on_body_animation_finished)

	attacking = false
	# Make sure we're not drifting after leaving this state.
	player.velocity = Vector2.ZERO


func Process(_delta: float) -> State:
	# While attacking is true we stay in this state.
	# Once the animation finishes (_on_body_animation_finished sets attacking = false),
	# OR if Enter() refused to start due to cooldown (attacking == false).
	if not attacking:
		if player.direction == Vector2.ZERO:
			return idle
		else:
			return walk

	return null


func Physics(_delta: float) -> State:
	# Smoothly decelerate the player during the attack.
	if player.velocity != Vector2.ZERO:
		var t: float = clampf(decelerate_speed * _delta, 0.0, 1.0)
		player.velocity = player.velocity.lerp(Vector2.ZERO, t)

		# Snap to full stop when we're not moving anymore.
		if player.velocity.length() < 1.0:
			player.velocity = Vector2.ZERO

	return null


func HandleInput(_event: InputEvent) -> State:
	# Add combo/buffer logic here later if you want.
	return null


func _on_body_animation_finished(anim_name: StringName) -> void:
	# Only end the attack when an Attack_* animation finishes.
	if anim_name.begins_with("Attack_"):
		attacking = false

		# Set the global cooldown so the next attack can't start
		# until `attack_cooldown_ms` has passed.
		var now_ms: int = Time.get_ticks_msec()
		_next_attack_allowed_time_ms = now_ms + attack_cooldown_ms
