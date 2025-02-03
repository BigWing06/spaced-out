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
	velocity.y += gravity
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpAmount
	if Input.is_action_pressed('moveRight'):
		velocity.x += movementSpeed/4
	if Input.is_action_pressed('moveLeft'):
		velocity.x -= movementSpeed/4
	if not Input.is_action_pressed("moveRight") and not Input.is_action_pressed("moveLeft") and velocity.x != 0:
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
	var tileMapPos = globals.getTileMapPos(position)
	if tileMapPos != prePos:
		tileMap.render(tileMapPos)
	prePos = tileMapPos
	var startPos = Vector2(tileMapPos.x-globals.renderDistance.x, tileMapPos.y-globals.renderDistance.y)
func getSavePos():
	return [position.x, position.y]
