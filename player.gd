extends CharacterBody2D

@export var speed = 400 # How fast the player will move (pixels/sec).
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
	
	if collider == self:
		return
	print("vaulting activated")
	if not collider.has_node("LeftMarker") or not collider.has_node("RightMarker"):
		push_warning("Vault object is missing LeftMarker or RightMarker")
		return
	
	is_vaulting = true
	$AnimatedSprite2D.play("vault")
	$CollisionShape2D.disabled = true
	
	var start_pos = global_position
	var peak_height = 20.0
	
	var target_marker: Marker2D
	
	# If player is on the left side of the object, vault to the right side
	if global_position.x < collider.global_position.x:
		target_marker = collider.get_node("RightMarker")
	else:
		target_marker = collider.get_node("LeftMarker")
	
	var target_pos = target_marker.global_position
	var mid_pos = Vector2(
		(start_pos.x + target_pos.x) / 2.0,
		min(start_pos.y, target_pos.y) - peak_height
	)
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", mid_pos, 0.18)
	tween.tween_property(self, "global_position", target_pos, 0.18)
	
	await tween.finished
	
	$CollisionShape2D.disabled = false
	is_vaulting = false

var current_vaultable = null

func _on_vault_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("vaultable"):
		current_vaultable = body
		print("entered vaultable:", body.name)

func _on_vault_detector_body_exited(body: Node2D) -> void:
	if body == current_vaultable:
		current_vaultable = null
		print("left vaultable:", body.name)

var detector_offset_x = 70.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_vaulting:
		return
	
	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1

	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0

	# Check vault BEFORE walk/idle animations
	if Input.is_action_just_pressed("vault") and current_vaultable:
		vault(current_vaultable)
		return

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		walk()
	elif Input.is_action_pressed("duck"):
		velocity = Vector2.ZERO
		duck()
	else:
		idle()
	
	move_and_collide(velocity * delta)
	if Input.is_action_just_pressed("vault") and current_vaultable:
		vault(current_vaultable)
