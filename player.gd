extends CharacterBody2D

@export var speed = 200 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size

func start(pos):
	position = pos
	show()

func duck():
	$AnimatedSprite2D.play("duck")
	$CollisionShape2D.shape.height = 120

func idle():
	$AnimatedSprite2D.play("idle")
	$CollisionShape2D.shape.height = 220

func walk():
	$AnimatedSprite2D.play("walk")
	$CollisionShape2D.shape.height = 220

var is_vaulting = false
func vault(collider):
	if is_vaulting:
		return

	is_vaulting = true
	$AnimatedSprite2D.play("vault")

	var object_width = collider.get_node("VaultableObject").shape.size.x
	var direction = -1 if $AnimatedSprite2D.flip_h else 1

	var start_pos = position
	var peak_height = 20.0
	var end_x = position.x + direction * (object_width + 20)

	# Keep collision off only during the vault
	$CollisionShape2D.disabled = true

	var tween = create_tween()

	# First half: move forward and up
	tween.tween_property(self, "position", Vector2(start_pos.x + direction * ((object_width + 20) / 2.0), start_pos.y - peak_height),0.18)

	# Second half: move forward and down
	tween.tween_property(self, "position", Vector2(start_pos.x + direction * (object_width + 100), start_pos.y), 0.18)

	await tween.finished
	await $AnimatedSprite2D.animation_finished

	$CollisionShape2D.disabled = false
	is_vaulting = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_vaulting:
		return

	velocity = Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		walk()
	elif Input.is_action_pressed("duck"):
		velocity = Vector2.ZERO
		duck()
	else:
		idle()

	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0

	var collision = move_and_collide(velocity * delta)
	if collision and Input.is_action_just_released("vault"):
		var collider = collision.get_collider()
		vault(collider)
