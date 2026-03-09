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
	$AnimatedSprite2D.animation = "duck"
	$AnimatedSprite2D.play()
	$CollisionShape2D.shape.height = 120

func idle():
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()
	$CollisionShape2D.shape.height = 220

func walk():
	$AnimatedSprite2D.animation = "walk"
	$AnimatedSprite2D.play()
	$CollisionShape2D.shape.height = 220

func vault(collider):
	hide()
	$CollisionShape2D.disabled = true
	var object_width = collider.get_node("VaultableObject").shape.size.x
	print(object_width)
	var start_position = position.x
	var direction = -1 if $AnimatedSprite2D.flip_h else 1
	if direction == 1:
		print(start_position)
		start_position += object_width
		print(start_position)
		position.x = start_position
	else: 
		start_position -= object_width
		position.x = start_position
	
	show()
	$CollisionShape2D.disabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity = Vector2.ZERO # The player's movement vector.

	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1

	if velocity.length() > 0:
		walk()
		velocity = velocity.normalized() * speed
	elif Input.is_action_pressed("duck"):
		duck()
		velocity = Vector2.ZERO
	else:
		idle()
	
	var collision = move_and_collide(velocity * delta)
	if collision && Input.is_action_just_released("vault"):
		var collider = collision.get_collider()
		vault(collider)

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0
