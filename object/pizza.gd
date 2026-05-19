extends RigidBody2D

var isBeingHeld: bool = false
var myParent: CharacterBody2D
var theWorld: Node
@export var freezeModeSetting: FreezeMode

var allowPickUp: bool = true
var firstItteration: bool = true

@onready var myMaxSpeed: float = 400.0

@onready var cooldownTimer: Timer = $Cooldown
@onready var cooldownLength: float = 0.25

var flickInput = Input.get_axis("flickLeft", "flickRight")

var dotTexture = load("res://gage/gageDot.png")

var joystickDevice: int = 0

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 20
	
	
func flickReleased(): # Basically a is_action_just_pressed() but for releasing a joystick axis
	print("Hello, World")
	
func _process(delta: float) -> void:
	var rightStickX: float = Input.get_joy_axis(joystickDevice, JOY_AXIS_RIGHT_X)
	var rightStickY: float = Input.get_joy_axis(joystickDevice, JOY_AXIS_RIGHT_Y)
	
	var input: Vector2 = Vector2(rightStickX, rightStickY)
	
	if isBeingHeld:
		predictTrajectory()
		
		hold(myParent.holdPointRight)
		# firstItteration = false
		
		var flickInput = Input.get_axis("flickLeft", "flickRight")
		
		if (abs(input.x) > 0.1 or abs(input.y) > 0.1) and Input.is_action_just_pressed("comfirmThrow"):
			if flickInput < 0:
				hold(myParent.holdPointLeft)
			elif flickInput > 0:
				hold(myParent.holdPointRight)
			#toss(myParent, flickInput)
			toss2(myParent, input)
			firstItteration = true
			deleteDots()

func equip(player: CharacterBody2D) -> void:
	isBeingHeld = true
	myParent = player
	self.reparent(player)
	theWorld = player.get_parent()
	myParent.object = self
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true
	lock_rotation = true
	rotation = 0
	linear_velocity = Vector2.ZERO
	

func hold(holdPoint: Marker2D) -> void:
	self.global_position = holdPoint.global_position
	# print("Hold function is currently being executed")

var dots: Array[Sprite2D] = []
var dotOffsetX: float = 5 # This offset is to move dots so they don't appear on top of the object. (for X)
var dotOffsetY: float = 2 # This offset is to move dots so they don't appear on top of the object. (for Y)

func createDot(x: float, y: float):
	var new_dot = Sprite2D.new()
	add_child(new_dot)
	new_dot.set_texture(dotTexture)
	new_dot.position = Vector2(x + dotOffsetX, y - dotOffsetY) # offset applied here instead of within predictTrajectory
	# If you want the dots to ignore the parent's movement, set top_level on the dot itself:
	#new_dot.top_level = true 
	dots.append(new_dot)
	
func deleteDots():
	for dot in dots:
		dot.queue_free()
	dots.clear()

var deadzone: float = 0.1
var spaceBetweenDots: float = 25.0

func predictTrajectory():
	deleteDots()
	var rightStickX: float = Input.get_joy_axis(joystickDevice, JOY_AXIS_RIGHT_X)
	var rightStickY: float = Input.get_joy_axis(joystickDevice, JOY_AXIS_RIGHT_Y)
	var input: Vector2 = Vector2(rightStickX, rightStickY)
	
	var numDots: int = 6
	if abs(input.x) > deadzone or abs(input.y) > deadzone:
		for x in numDots:
			createDot(rightStickX * spaceBetweenDots * x, input.y * spaceBetweenDots* x)
			print(x)

func toss(player: CharacterBody2D, directionX: float) -> void:
	var toss_direction = Vector2(directionX, -0.5).normalized()
	release(player)
	linear_velocity = toss_direction * myMaxSpeed
	cooldownTimer.start(cooldownLength)
	allowPickUp = false
	
func toss2(player: CharacterBody2D, direction: Vector2):
	var toss_direction = Vector2(direction.x, direction.y).normalized()
	release(player)
	linear_velocity = toss_direction * myMaxSpeed
	cooldownTimer.start(cooldownLength)
	allowPickUp = false
	
	
func release(player: CharacterBody2D) -> void:
	var global_pos = global_position
	#player.remove_child(self)
	self.reparent(theWorld)
	global_position = global_pos 
	isBeingHeld = false
	myParent = null
	freeze = false
	lock_rotation = false

func detectPlayer(body: Node2D) -> void:
	if body.is_in_group("player") and allowPickUp:
		print("player")
		equip(body)
		allowPickUp = false

func reenablePickUp() -> void:
	if !allowPickUp:
		allowPickUp = true
