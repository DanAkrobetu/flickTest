extends CharacterBody2D

@export var maxSpeed: float = 200
@export var maxJumpHeight: float = 300

@export var upwardsGravityMultiplier: float = 0.5
@export var donwardsGravityMultiplier: float = 0.0

var canDoubleJump: bool = false
var canAirFaultDoubleJump: bool = true

var objectVelocityX
var objectVelocityY

@onready var holdPointRight = $holdPointRight
@onready var holdPointLeft = $holdPointLeft

var isHoldingObject: bool = false

var object: RigidBody2D

func _ready() -> void:
	velocity = Vector2.ZERO
 
func get_input():
	var inputDir = Input.get_axis("left", "right")
	velocity.x = inputDir * maxSpeed

	# Ground jump
	if is_touching_feet():
		canDoubleJump = true
		canAirFaultDoubleJump = true
		
		if Input.is_action_just_pressed("jump"):
			velocity.y = -maxJumpHeight * upwardsGravityMultiplier

	# Air jump (works even if you walked off a ledge)
	elif canDoubleJump and Input.is_action_just_pressed("jump"):
		velocity.y = -maxJumpHeight * upwardsGravityMultiplier
		canDoubleJump = false
		#print("doube jump")
	elif detectMovingDown() and !canDoubleJump and canAirFaultDoubleJump and Input.is_action_just_pressed("jump"):
		velocity.y = -maxJumpHeight * upwardsGravityMultiplier
		canDoubleJump = false
		canAirFaultDoubleJump = false
	
	#print("InputDir:" + str(inputDir))
	#print("velocity.y:" + str(velocity.y))
	#print(sign(velocity.y))

func is_touching_feet() -> bool:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()

		if normal.y < -0.5:
			return true
	return false

func allowedToDoubleJump() -> bool:
	if is_touching_feet() and Input.is_action_just_pressed("jump"):
		canDoubleJump = true
		return true
	elif !is_touching_feet() and canDoubleJump and Input.is_action_just_pressed("jump"):
		canDoubleJump = false
		return true
	
		
	else:
		return false

func detectMovingDown() -> bool:
	return velocity.y > 0

func _process(_delta: float) -> void:
	if isHoldingObject:
		object.hold()
func _physics_process(delta: float) -> void:
	if !is_touching_feet():
		if detectMovingDown():
			velocity += delta * get_gravity() * donwardsGravityMultiplier
		else:
			velocity += delta * get_gravity()
	
	get_input()
	move_and_slide()
