extends KinematicBody

#stats
var curHp : int = 10
var maxHp : int = 10
var ammo : int = 15
var score : int = 0

#shooting bullets variables
onready var muzzle = get_node("Camera/GunModel/Muzzle")
onready var bulletScene = preload("res://Scenes/Bullet.tscn")

#reference UI node
onready var ui : Node = get_node("/root/MainScene/CanvasLayer/UI")

#physics
var moveSpeed: float = 5.0
var jumpForce : float = 5.0
var gravity : float = 12.0

#cam look
var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0
var lookSensitivity : float = 0.5

#vectors
var vel : Vector3 = Vector3()
var mouseDelta : Vector2 = Vector2()

#player components
onready var camera = get_node("Camera")

func _ready ():
	#hide and lock the mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	#set the UI
	ui.update_health_bar(curHp, maxHp)
	ui.update_ammo_text(ammo)
	ui.update_score_text(score)

func _input (event):
	
	if event is InputEventMouseMotion:
		mouseDelta = event.relative

func _process (delta):
	#Rotate camera along x axis, clamp vertical camera rotation, rotate player along Y axis, reset mouse delta vector
	camera.rotation_degrees -= Vector3(rad2deg(mouseDelta.y), 0, 0) * lookSensitivity * delta
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
	rotation_degrees -= Vector3(0, rad2deg(mouseDelta.x), 0) * lookSensitivity * delta
	mouseDelta = Vector2()
	
	#check to see if shooting
	if Input.is_action_just_pressed("shoot") and ammo > 0:
		shoot()
	
func _physics_process (Delta):
	#reset velocity
	vel.x = 0
	vel.z = 0
	
	var input = Vector2()
	
	#movement input and normalizes input so the player can not move faster diagonally as a result of compounding vectors
	if Input.is_action_pressed("move_forward"):
		input.y -= 1
	if Input.is_action_pressed("move_backward"):
		input.y += 1
	if Input.is_action_pressed("move_left"):
		input.x -= 1
	if Input.is_action_pressed("move_right"):
		input.x += 1
	
	input = input.normalized()
	
	#get our forward and right directions, set velocity, apply gravity, move player, jump action
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
	
	vel.z = (forward * input.y + right * input.x).z * moveSpeed
	vel.x = (forward * input.y + right * input.x).x * moveSpeed
	
	vel.y -= gravity * Delta
	
	vel = move_and_slide(vel, Vector3.UP)
	
	if Input.is_action_pressed("jump") and is_on_floor():
		vel.y = jumpForce

func shoot():
	
	var bullet = bulletScene.instance()
	get_node("/root/MainScene").add_child(bullet)
	
	$Gunshot.playing = true
	bullet.global_transform = muzzle.global_transform
	bullet.scale = Vector3.ONE
	ammo -= 1
	
	ui.update_ammo_text(ammo)

func take_damage (damage):
	curHp -= damage
	if curHp <= 0:
		die()
	
	ui.update_health_bar(curHp, maxHp)

func die():
	queue_free()

func add_score (amount):
	score += amount
	$Boop.playing = true
	ui.update_score_text(score)

func add_health (amount):
	curHp = clamp(curHp + amount, 0, maxHp)
	$Ring.playing = true
	ui.update_health_bar(curHp, maxHp)

func add_ammo (amount):
	ammo += amount
	$Ring.playing = true
	ui.update_ammo_text(ammo)
