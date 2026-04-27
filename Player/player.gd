extends CharacterBody2D

const maxSpeed: float = 500
const maxJumpHeight: float = 1000

@export var upwardsGravityMultiplier: float = 2.5
@export var donwardsGravityMultiplier: float = 1.65

var doubleJump: bool = false


var objectVelocityX
var objectVelocityY

@onready var holdPointRight = $holdPointRight
@onready var holdPointLeft = $holdPointLeft

var isHoldingObject: bool = false

var object: RigidBody2D

signal drop_item


func _ready() -> void:
	velocity = Vector2.ZERO
 
func get_input():
	var inputDir = Input.get_axis("left", "right")
	velocity.x = inputDir * maxSpeed
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		#print("jump")
		velocity.y = -(maxJumpHeight)
	elif !is_on_floor() and !doubleJump and Input.is_action_just_pressed("jump"):
		velocity.y = -(maxJumpHeight)
		doubleJump = true
		#print("doube jump")
	
	#print("InputDir:" + str(inputDir))
	#print("velocity.y:" + str(velocity.y))
	#print(sign(velocity.y))


func detectFlick():
	var flickInput = Input.get_axis("flickLeft", "flickRight")
	
	
	objectVelocityX = flickInput * maxSpeed
	var thing = false
	emit_signal("drop_item")

func detectMovingDown() -> bool:
	return velocity.y > 0

func _process(delta: float) -> void:
	if isHoldingObject:
		object.hold()

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
	detectFlick()

	move_and_slide()
