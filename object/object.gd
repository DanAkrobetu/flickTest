extends Node
class_name ObjectLogic

@export var gravity: float = 1000.0

var velocityX: float = 0.0
var velocityY: float = 0.0

func _ready() -> void:
	$Sprite.modulate = Color(1, 0, 0) # Tint red
