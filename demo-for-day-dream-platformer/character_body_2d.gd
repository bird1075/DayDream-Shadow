extends CharacterBody2D

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0

var jumps: int = 0
var air_friction: float = 20.0  # How fast you slow down in air

var spawn_position: Vector2 = Vector2(0, 0)
var spawn_positionbad: Vector2 = Vector2(1000, 1000)
var spawn_positiongood: Vector2 = Vector2(500, -100)
var fall_limit_y: float = 1000.0

var lives: int = 3
var karma: int = 0

@onready var jump_sound = $JumpSound
@onready var walk_sound = $WalkSound

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if position.y > fall_limit_y and karma > 0:
		position = spawn_positiongood
		lives -= 1
	else: if position.y > fall_limit_y and karma < 0:
		position = spawn_positionbad
		
	else: if position.y > fall_limit_y and karma == 0:
		position = spawn_position

		velocity = Vector2.ZERO

	# --- Gravity ---
	if not is_on_floor():
		velocity += get_gravity() * delta

	# --- Collision checks ---
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider.is_in_group("GoodNPC"):
			position = spawn_positiongood
			karma += 1
			get_tree().change_scene_to_file("res://good.tscn")
		else: if collider.is_in_group("BadNPC"):
			position = spawn_positionbad
			karma -= 1
			get_tree().change_scene_to_file("res://bad.tscn")
		else: if collider.is_in_group("Enemy"):
				position = spawn_position
		break

	# --- Jumping ---
	if Input.is_action_just_pressed("move up") and jumps > 1:
		jumps -= 1
		velocity.y = JUMP_VELOCITY
		jump_sound.play()

	if is_on_floor():
		jumps = 3

	if jumps < 0:
		jumps = 0

	# --- Horizontal movement ---
	var direction: float = Input.get_axis("move left", "move right")
	if direction != 0.0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	# --- Animation handling ---
	if is_on_floor():
		if direction > 0.0:
			$AnimatedSprite2D.play("Run Right")
		elif direction < 0.0:
			$AnimatedSprite2D.play("Run Left")
		else:
			# Use last facing side for idle
			walk_sound.play()
			if $AnimatedSprite2D.animation.ends_with("Right"):
				$AnimatedSprite2D.play("Idle Right")
			else:
				$AnimatedSprite2D.play("Idle Left")

	move_and_slide()
