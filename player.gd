extends Area2D

@export var speed = 600 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size

func start(pos):
	position = pos
	show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.play()
		$CollisionShape2D.shape.height = 220
	elif Input.is_action_pressed("duck"):
		$AnimatedSprite2D.animation = "duck"
		$AnimatedSprite2D.play()
		$CollisionShape2D.shape.height = 120
		velocity = Vector2.ZERO
	else:
		$AnimatedSprite2D.animation = "idle"
		$AnimatedSprite2D.play()
		$CollisionShape2D.shape.height = 220
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0
