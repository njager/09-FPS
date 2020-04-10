extends Area

enum PickupType {
	Health,
	Ammo
}

#stats and bobbing variables
export(PickupType) var type = PickupType.Health
export var amount : int = 10
onready var startYPos : float = translation.y
var bobHeight : float = 1.0
var bobSpeed : float = 1.0
var bobbingUp : bool = true

func _process (delta):
	#move up or down, thenif at the top move downwards and if at bottom move up
	translation.y += (bobSpeed if bobbingUp else -bobSpeed) * delta
	if bobbingUp and translation.y > startYPos + bobHeight:
		bobbingUp = false
	elif !bobbingUp and translation.y < startYPos:
		bobbingUp = true

func _on_Pickup_body_entered (body):
	if body.name == "Player":
		pickup(body)
		queue_free()

func pickup (player):
	if type == PickupType.Health:
		player.add_health(amount)
	elif type == PickupType.Ammo:
		player.add_ammo(amount)
