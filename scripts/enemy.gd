extends CharacterBody2D

enum State { IDLE, PATROL, CHASE, ATTACK, DEATH }
var current_state = State.PATROL

const SPEED = 60.0
const CHASE_SPEED = 80.0
var direction = 1
var player = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var edge_check = $EdgeCheck
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	if current_state == State.DEATH:
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	match current_state:
		State.IDLE:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			animated_sprite.play("idle")
		State.PATROL:
			patrol_state()
		State.CHASE:
			chase_state()
		State.ATTACK:
			velocity.x = 0
			animated_sprite.play("attack")

	move_and_slide()

func patrol_state():
	if not edge_check.is_colliding() or is_on_wall():
		direction *= -1
		update_facing()

	velocity.x = direction * SPEED
	animated_sprite.play("walk")

func chase_state():
	if player != null:
		var dir_to_player = sign(player.global_position.x - global_position.x)
		
		if dir_to_player != 0 and dir_to_player != direction:
			direction = dir_to_player
			update_facing()
			
	velocity.x = direction * CHASE_SPEED
	animated_sprite.play("run")

func update_facing():
	animated_sprite.flip_h = direction < 0
	edge_check.position.x = abs(edge_check.position.x) * direction
	if has_node("Hitbox"):
		$Hitbox.position.x = abs($Hitbox.position.x) * direction

func _on_player_detect_body_entered(body):
	if current_state == State.DEATH:
		return
		
	if body.name == "Player":
		player = body
		current_state = State.CHASE

func _on_player_detect_body_exited(body):
	if body.name == "Player":
		player = null
		current_state = State.PATROL

func die():
	current_state = State.DEATH
	velocity.x = 0
	animated_sprite.play("death")
	
	# Shout to the HUD group to run the add_score function with 100 points!
	get_tree().call_group("HUD", "add_score", 100)

func _on_hitbox_body_entered(body):
	if current_state == State.DEATH:
		return
		
	if body.name == "Player":
		current_state = State.ATTACK
		body.die()

func _on_animated_sprite_2d_animation_finished():
	if current_state == State.ATTACK:
		current_state = State.CHASE
	elif current_state == State.DEATH:
		queue_free()


func _on_headbox_body_entered(body):
	if current_state == State.DEATH:
		return
		
	if body.name == "Player":
		# 1. Make the player bounce off the head
		body.velocity.y = body.JUMP_VELOCITY 
		
		# 2. Tell the enemy to die
		die()
