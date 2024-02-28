extends Area2D

signal hit

# @export lets you see and set these variables in the Godot Editor
@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
		# $ is shorthand for get_node(). So in the code above,
		# $AnimatedSprite2D.play() is the same as get_node("AnimatedSprite2D").play()
	else:
		$AnimatedSprite2D.stop()
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "horizontal_movement"
		# Disallowing the vertical flipping is necessary since
		# the animation could be flipped in the previous iteration of the _process method
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0 # Flip horizontally if moving left
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "vertical_movement"
		$AnimatedSprite2D.flip_v = velocity.y > 0 # Flip vertically if moving down

	# The delta parameter in the _process() function refers to the
	# frame length - the amount of time that the previous frame took to complete. Using this
	# value ensures that your movement will remain consistent even if the frame rate changes.
	position += velocity * delta
	# We can also use clamp() to prevent the player sprite from leaving the screen.
	# Clamping a value means restricting it to a given range.
	position = position.clamp(Vector2.ZERO, screen_size)


func enemy_collision(body):
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)


func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
