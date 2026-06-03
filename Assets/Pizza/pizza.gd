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

var dotTexture = load("res://Assets/Pizza/gage/gageDot.png")

var joystickDevice: int = 0

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 20
	
	
func flickReleased(): # Basically a is_action_just_pressed() but for releasing a joystick axis
	print("Hello, World")
	
func _process(delta: float) -> void:
	#print("Global ", self.global_position)
	
	var rightStickX: float = Input.get_joy_axis(joystickDevice, JOY_AXIS_RIGHT_X)
	var rightStickY: float = Input.get_joy_axis(joystickDevice, JOY_AXIS_RIGHT_Y)
	
	var input: Vector2 = Vector2(rightStickX, rightStickY)
	
	if isBeingHeld:
		predictTrajectory(delta)
		
		hold(myParent.holdPointRight)
		# firstItteration = false
		
		var flickInput = Input.get_axis("flickLeft", "flickRight")
		
		if (abs(input.x) > 0.1 or abs(input.y) > 0.1):
			if flickInput < 0:
				hold(myParent.holdPointLeft)
			elif flickInput > 0:
				hold(myParent.holdPointRight)
			
			if Input.is_action_just_pressed("comfirmThrow"):
				toss(input)
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

func createDot(global_pos: Vector2):
	var new_dot = Sprite2D.new()
	new_dot.texture = dotTexture
	new_dot.top_level = true
	new_dot.global_position = global_pos
	add_child(new_dot)
	dots.append(new_dot)
	
func deleteDots():
	for dot in dots:
		dot.queue_free()
	dots.clear()

var deadzone: float = 0.1
var spaceBetweenDots: float = 25.0

var worldGravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
#var time

func predictTrajectory(_delta: float):
	deleteDots()
	var rightStickX: float = Input.get_joy_axis(joystickDevice, JOY_AXIS_RIGHT_X)
	var rightStickY: float = Input.get_joy_axis(joystickDevice, JOY_AXIS_RIGHT_Y)
	var input: Vector2 = Vector2(rightStickX, rightStickY)
	
	if input.length() > deadzone:
		var throw_direction: Vector2 = input.normalized()
		var initial_velocity: Vector2 = throw_direction * myMaxSpeed
		var start_position: Vector2 = global_position
		var numDots: int = 6
		var time_step: float = 0.12
		
		var gravity_vector: Vector2 = Vector2.DOWN * worldGravity * gravity_scale
		
		for i in range(numDots):
			var t: float = time_step * float(i + 1)
			var predicted_position: Vector2 = start_position + initial_velocity * t + 0.5 * gravity_vector * t * t
			createDot(predicted_position)


func toss(direction: Vector2):
	var toss_direction = Vector2(direction.x, direction.y).normalized()
	release()
	linear_velocity = toss_direction * myMaxSpeed
	cooldownTimer.start(cooldownLength)
	allowPickUp = false

func release() -> void:
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
		equip(body)
		allowPickUp = false

func reenablePickUp() -> void:
	if !allowPickUp:
		allowPickUp = true
		
func pizza():
	print("im a pizza (Even though I don't look like it)")
