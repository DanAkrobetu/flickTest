extends CharacterBody2D

@export var maxSpeed: float = 200
@export var maxJumpHeight: float = 300

@export var upwardsGravityMultiplier: float = 0.5
@export var donwardsGravityMultiplier: float = 0.0

var doubleJump: bool = false

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
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		#print("jump")
		velocity.y = -(maxJumpHeight) * upwardsGravityMultiplier
	elif !is_on_floor() and !doubleJump and Input.is_action_just_pressed("jump"):
		velocity.y = -(maxJumpHeight) * upwardsGravityMultiplier
		doubleJump = true
		#print("doube jump")
	
	#print("InputDir:" + str(inputDir))
	#print("velocity.y:" + str(velocity.y))
	#print(sign(velocity.y))

func detectMovingDown() -> bool:
	return velocity.y > 0

func _process(_delta: float) -> void:
	if isHoldingObject:
		object.hold()

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		if detectMovingDown():
			velocity += delta * get_gravity() * donwardsGravityMultiplier
		else:
			velocity += delta * get_gravity() * donwardsGravityMultiplier
	elif is_on_floor():
		doubleJump = false
	get_input()
	move_and_slide()
