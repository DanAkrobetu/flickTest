extends RigidBody2D

var isBeingHeld: bool = false
var myParent: CharacterBody2D
var theWorld: Node
@export var freezeModeSetting: FreezeMode

var allowPickUp: bool = true

var myMaxSpeed: float = 800.0

@onready var cooldownTimer: Timer = $Cooldown
const cooldownLength: float = 0.25

var flickInput = Input.get_axis("flickLeft", "flickRight")


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 20
	
	
func _process(delta: float) -> void:
	if isBeingHeld:
		hold(myParent.holdPointRight)
		
		var flickInput = Input.get_axis("flickLeft", "flickRight")
		
		if abs(flickInput) > 0.1:
			if flickInput < 0:
				hold(myParent.holdPointLeft)
				toss(myParent, flickInput)
			elif flickInput > 0:
				hold(myParent.holdPointRight)
				toss(myParent, flickInput)

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


func toss(player: CharacterBody2D, direction: float) -> void:
	var toss_direction = Vector2(direction, -0.5).normalized()
	release(player)
	linear_velocity = toss_direction * myMaxSpeed
	cooldownTimer.start(cooldownLength)
	allowPickUp = false

func release(player: CharacterBody2D) -> void:
	var global_pos = global_position          # save position BEFORE reparenting
	#player.remove_child(self)
	self.reparent(theWorld)
	global_position = global_pos             # restore position to avoid teleport
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
