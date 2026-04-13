extends CharacterBody2D

const maxSpeed: float = 500
const maxJumpHeight: float = 500

const upwardsGravityMultiplier: float = 1.5
const donwardsGravityMultiplier: float = 1.5

var doubleJump: bool = false


func _ready() -> void:
	velocity = Vector2.ZERO
 
func get_input():
	var inputDir = Input.get_axis("left", "right")
	velocity.x = inputDir * maxSpeed
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		#print("jump")
		velocity.y = -(maxJumpHeight * upwardsGravityMultiplier)
	elif !is_on_floor() and !doubleJump and Input.is_action_just_pressed("jump"):
		velocity.y = maxJumpHeight * upwardsGravityMultiplier
		doubleJump = true
		#print("doube jump")
	
	#print("InputDir:" + str(inputDir))
	print("velocity.y:" + str(velocity.y))
	#print(sign(velocity.y))
	
func detectMovingDown() -> bool:
	return velocity.y > 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if !is_on_floor():
		if detectMovingDown():
			velocity += delta * get_gravity() * donwardsGravityMultiplier
		else:
			velocity += delta * get_gravity()
	elif is_on_floor():
		doubleJump = false
	get_input()

	move_and_slide()
