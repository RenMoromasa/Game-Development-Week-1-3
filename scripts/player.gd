extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") + 140.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var sfx_jump = $SFXJump
@onready var sfx_death = $SFXDeath
@onready var sfx_Running = $SFXRunning

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		sfx_Running.stop()

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		sfx_jump.play()

	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
	else:
		if direction != 0:
			animated_sprite.play("run")
			if not sfx_Running.playing:
				sfx_Running.play()
		else:
			animated_sprite.play("idle")
			sfx_Running.stop()

	move_and_slide()
	
func die():
	set_physics_process(false)
	sfx_Running.stop()
	sfx_death.play()
	animated_sprite.play("death")
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
