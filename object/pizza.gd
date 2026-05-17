extends RigidBody2D

var isBeingHeld: bool = false
var myParent: CharacterBody2D
var theWorld: Node
@export var freezeModeSetting: FreezeMode

var allowPickUp: bool = true
var firstItteration: bool = true

@onready var myMaxSpeed: float = 800.0

@onready var cooldownTimer: Timer = $Cooldown
@onready var cooldownLength: float = 0.25

var flickInput = Input.get_axis("flickLeft", "flickRight")

var dotTexture = load("res://gage/gageDot.png")


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 20
	
func _process(delta: float) -> void:
	if isBeingHeld:
		predictTrajectory(20, 20)
		
		hold(myParent.holdPointRight)
		# firstItteration = false
		
		var flickInput = Input.get_axis("flickLeft", "flickRight")
		
		if abs(flickInput) > 0.1:
			if flickInput < 0:
				hold(myParent.holdPointLeft)
				#toss(myParent, flickInput)
				firstItteration = true
			elif flickInput > 0:
				hold(myParent.holdPointRight)
				#toss(myParent, flickInput)
				firstItteration = true

func equip(player: CharacterBody2D) -> void:
	isBeingHeld = true
	myParent = player
	self.reparent(player)
	theWorld = player.get_parent()
	myParent.object = self
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true
	lock_rotation = true
	linear_velocity = Vector2.ZERO
	

func hold(holdPoint: Marker2D) -> void:
	self.global_position = holdPoint.global_position
	# print("Hold function is currently being executed")

var dots: Array[Sprite2D] = []

func createDot(x: float, y: float):
	var new_dot = Sprite2D.new()
	add_child(new_dot)
	new_dot.set_texture(dotTexture)
	new_dot.position = Vector2(x, y)
	# If you want the dots to ignore the parent's movement, set top_level on the dot itself:
	#new_dot.top_level = true 
	dots.append(new_dot)
	
func deleteDots():
	for dot in dots:
		dot.queue_free()
	dots.clear()

var deadzone: float = 0.2

func predictTrajectory(xPos: float, yPos: float):
	deleteDots()
	var joystickDevice: int = 0
	var rightStickX: float = Input.get_joy_axis(joystickDevice, JOY_AXIS_RIGHT_X)
	
	var numDots: int = 20
	if abs(rightStickX) > deadzone:
		for x in numDots:
			createDot(rightStickX * 25 * x, 0)
			print(x)
			#print(rightStickX * 100 * itteration)
		
	

func toss(player: CharacterBody2D, direction: float) -> void:
	var toss_direction = Vector2(direction, -0.5).normalized()
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
