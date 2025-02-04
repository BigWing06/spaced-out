extends KinematicBody2D
onready var globals = get_node("/root/global")
onready var planetInfo = globals.worldInfo[globals.currentPlanet]
onready var gravity = planetInfo['world']['gravity']
onready var jumpAmount = gravity*-30
onready var playerInfo = globals.playerInfo
onready var movementSpeed = playerInfo['movementSpeed']
onready var tileMap = get_parent().get_node("TileMap")
onready var mineTilemap = get_parent().get_node("miningTileMap")
onready var mineTimer = get_parent().get_node("mineTimer")
var mineCells = []
var mineCellState = -1
var mineStartPos
var timerActive = false
var prePos = null
var direction = 1
var mining = false
var stop = false

var velocity = Vector2.ZERO

func _ready():
	position = globals.playerStartPos[1]

func _physics_process(delta):
	var moveRight = Input.is_action_pressed("playerTwoMoveRight")
	var moveLeft = Input.is_action_pressed("playerTwoMoveLeft")
	var jump = Input.is_action_pressed("playerTwoJump")
	velocity.y += gravity
	if jump and is_on_floor():
		velocity.y = jumpAmount
	if moveRight:
		velocity.x += movementSpeed/4
	if moveLeft:
		velocity.x -= movementSpeed/4
	if not moveRight and not moveLeft and velocity.x != 0:
		if velocity.x > 0:
			velocity.x += movementSpeed/4*(velocity.x/abs(velocity.x)*-1)
			velocity.x = clamp(velocity.x, 0, 100)
		else:
			velocity.x += movementSpeed/4*(velocity.x/abs(velocity.x)*-1)
			velocity.x = clamp(velocity.x, -100, 0)
	velocity.y = clamp(velocity.y, jumpAmount, gravity*25)
	velocity.x = clamp(velocity.x, -movementSpeed, movementSpeed)
	
	#Determines direction character faces
	var preDirection = direction
	if velocity.x > 0:
		direction = 1
	if velocity.x < 0:
		direction = -1
	if direction != preDirection:
		scale.x = -1
		
	velocity = move_and_slide(velocity, Vector2.UP)
func getSavePos():
	return [position.x, position.y]
