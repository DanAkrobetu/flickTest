extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var firstInstance: bool = true
var direction = 0.3

func startTimer():
	if firstInstance:
		$Timer.wait_time = 5
		$Timer.start()
		firstInstance = false

func _physics_process(delta: float) -> void:
	startTimer()
	if not is_on_floor():
		velocity += get_gravity() * delta

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func _on_timer_timeout() -> void:
	print("Condition met")
	$Timer.wait_time = 5
	$Timer.start()
	direction = -direction
	print(direction)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("pizza"):

		changeColor()

func changeColor() -> void:
	var random_color = Color(randf(), randf(), randf(), 1.0)
	$Sprite2D.modulate = random_color
