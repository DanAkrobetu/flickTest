extends CharacterBody2D

const maxSpeed: float = 500
const maxJumpHeight: float = 500

var doubleJump: bool = false

func _ready() -> void:
	velocity = Vector2.ZERO

	 
func get_input():
	var inputDir = Input.get_axis("left", "right")
	velocity.x = inputDir * maxSpeed
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		print("jump")
		velocity.y -= maxJumpHeight
	elif !is_on_floor() and !doubleJump and Input.is_action_just_pressed("jump"):
		velocity.y -= maxJumpHeight
		doubleJump = true
		print("doube jump")
	
	#print("InputDir:" + str(inputDir))
	#print("velocity.x:" + str(velocity.x))
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if !is_on_floor():
		velocity += delta * get_gravity()
	elif is_on_floor():
		doubleJump = false
	get_input()

	

	move_and_slide()
